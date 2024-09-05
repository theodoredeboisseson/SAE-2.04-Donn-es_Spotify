/*1. Pour chaque morceau (ou piste) le nombre d'interprètes, le nombre d'écoutes, le nombre d'écoutes en cours,'
'l'évaluation moyenne, le nombre de likes, le nombre de playlists qui contiennent le morceau,
le nombre de playlists où le morceau est en première position, le nombre de partages. */

-- Nombre d'interprètes et d'écoutes par morceau
CREATE OR REPLACE VIEW v1_1 AS
SELECT t.IDTRACK,
       COUNT(DISTINCT pb.IDARTIST) AS "Nb Interprètes",
       COUNT(ld.IDTRACK)           AS Ecoutes
FROM TRACKS t
         JOIN ALBUMS al ON t.IDALBUM = al.IDALBUM
         JOIN PRODUCEDBY pb ON al.IDALBUM = pb.IDALBUM
         JOIN LISTENINGDATE ld ON t.IDTRACK = ld.IDTRACK
GROUP BY t.IDTRACK, t.NAME;

-- Nombre d'écoutes actuelles et note moyenne par morceau
CREATE OR REPLACE VIEW v1_2 AS
SELECT t.IDTRACK,
       COUNT(u.IDCURRENTTRACK)             AS "Ecoutes actuelles",
       COALESCE(ROUND(AVG(ev.note), 2), 0) AS "Note moyenne"
FROM TRACKS t
         LEFT JOIN USERS u ON t.IDTRACK = u.IDCURRENTTRACK
         LEFT JOIN EVALUATIONS ev ON t.IDTRACK = ev.IDTRACK
GROUP BY t.IDTRACK;

-- Nombre de likes par morceau
CREATE OR REPLACE VIEW v1_3 AS
SELECT t.IDTRACK, COUNT(lb.IDTRACK) AS Likes
FROM TRACKS t
         LEFT JOIN LIKEDBY lb ON t.IDTRACK = lb.IDTRACK
GROUP BY t.IDTRACK;

-- Nombre de partages par morceau
CREATE OR REPLACE VIEW v1_4 AS
SELECT t.IDTRACK, COUNT(st.IDSHAREDTRACK) AS Partages
FROM TRACKS t
         LEFT JOIN SHARETRACK st ON t.IDTRACK = st.IDSHAREDTRACK
GROUP BY t.IDTRACK;

-- Nombre de playlists contenant le morceau
CREATE OR REPLACE VIEW v1_5 AS
SELECT t.IDTRACK, COUNT(pc.IDTRACK) AS "Dans des playlists"
FROM TRACKS t
         LEFT JOIN PLAYLISTCONTENT pc ON t.IDTRACK = pc.IDTRACK
GROUP BY t.IDTRACK;

-- Nombre de playlists où le morceau est en 1ère position
CREATE OR REPLACE VIEW v1_6 AS
SELECT t.IDTRACK, COUNT(pc.IDTRACK) AS "1er dans les playlists"
FROM TRACKS t
         LEFT JOIN (SELECT * FROM PLAYLISTCONTENT WHERE NBRANK = 1) pc ON pc.IDTRACK = t.IDTRACK
GROUP BY t.IDTRACK;

-- On rassemble les vues
create or replace view vue1 as
select t.IDTRACK,
       t.NAME,
       "Nb Interprètes",
       Ecoutes,
       "Ecoutes actuelles",
       "Note moyenne",
       Likes,
       "Dans des playlists",
       "1er dans les playlists",
       Partages
FROM TRACKS t
         join v1_1 v1 on t.IDTRACK = v1.IDTRACK
         join v1_2 v2 on t.IDTRACK = v2.IDTRACK
         join v1_3 v3 on t.IDTRACK = v3.IDTRACK
         join v1_4 v4 on t.IDTRACK = v4.IDTRACK
         join v1_5 v5 on t.IDTRACK = v5.IDTRACK
         join v1_6 v6 on t.IDTRACK = v6.IDTRACK
order by name;

/*2. Pour chaque album, le nombre de morceaux, le morceau le moins écouté et le morceau le plus écouté.*/


-- Morceau le moins écouté pour chaque Album
CREATE OR REPLACE VIEW v2_1 AS
SELECT a.IDALBUM,
       t.name AS "Morceau le moins écouté"
FROM Albums a
         JOIN Tracks t ON a.idAlbum = t.idAlbum
         LEFT JOIN ListeningDate ld ON t.idTrack = ld.idTrack
GROUP BY a.idAlbum, t.idTrack, a.name, t.name
HAVING COUNT(ld.idTrack) = (SELECT MIN(COUNT(ld2.idTrack)) AS count_ld
                            FROM Tracks t2
                                     LEFT JOIN ListeningDate ld2 ON t2.idTrack = ld2.idTrack
                            WHERE t2.idAlbum = a.IDALBUM
                            GROUP BY t2.idTrack);


-- Morceau le plus écouté pour chaque Album
CREATE OR REPLACE VIEW v2_2 AS
SELECT a.IDALBUM,
       t.name AS "Morceau le plus écouté"
FROM Albums a
         JOIN Tracks t ON a.idAlbum = t.idAlbum
         LEFT JOIN ListeningDate ld ON t.idTrack = ld.idTrack
GROUP BY a.idAlbum, t.idTrack, a.name, t.name
HAVING COUNT(ld.idTrack) = (SELECT MAX(COUNT(ld2.idTrack)) AS count_ld
                            FROM Tracks t2
                                     LEFT JOIN ListeningDate ld2 ON t2.idTrack = ld2.idTrack
                            WHERE t2.idAlbum = a.IDALBUM
                            GROUP BY t2.idTrack);

-- On rajoute le nb de morceaux par Album
create or replace view vue2 as
select a.name   AS Album,
       "Morceau le moins écouté",
       "Morceau le plus écouté",
       count(*) as nbMorceaux
FROM ALBUMS a
         join v2_1 v1 on a.IDALBUM = v1.IDALBUM
         join v2_2 v2 on a.IDALBUM = v2.IDALBUM
         join TRACKS t on a.IDALBUM = t.IDALBUM
group by a.name, "Morceau le moins écouté", "Morceau le plus écouté";


/* 3. Le morceau le plus écouté pour chacun des signes astrologiques des utilisateurs.*/


CREATE OR REPLACE VIEW v3_1 AS
SELECT idUser,
       CASE
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 2 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 19) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 3 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 20) THEN 'POISSONS'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 3 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 21) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 4 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 19) THEN 'BELIER'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 4 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 20) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 5 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 20) THEN 'TAUREAUX'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 5 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 21) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 6 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 20) THEN 'GEMEAUX'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 6 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 21) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 7 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 22) THEN 'CANCER'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 7 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 23) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 8 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 22) THEN 'LION'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 8 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 23) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 9 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 22) THEN 'VIERGE'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 9 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 23) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 10 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 22) THEN 'BALANCE'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 10 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 23) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 11 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 21) THEN 'SCORPION'
           WHEN (EXTRACT(MONTH FROM DATEOFBIRTH) = 11 AND EXTRACT(DAY FROM DATEOFBIRTH) >= 22) OR
                (EXTRACT(MONTH FROM DATEOFBIRTH) = 12 AND EXTRACT(DAY FROM DATEOFBIRTH) <= 21) THEN 'SAGITTAIRE'
           ELSE 'CAPRICORNE'
           END AS signeAstrologique
FROM Users;


CREATE OR REPLACE VIEW VUE3 AS
WITH EcoutesParSigne AS (SELECT v.signeAstrologique,
                                d.idTrack,
                                COUNT(*) AS nombreEcoutes
                         FROM LISTENINGDATE d
                                  JOIN v3_1 v ON d.idUser = v.idUser
                         GROUP BY v.signeAstrologique,
                                  d.idTrack),
     MaxEcoutesParSigne AS (SELECT signeAstrologique,
                                   MAX(nombreEcoutes) AS maxEcoutes
                            FROM EcoutesParSigne
                            GROUP BY signeAstrologique)
SELECT e.signeAstrologique,
       t.idTrack,
       t.NAME,
       e.nombreEcoutes
FROM EcoutesParSigne e
         JOIN MaxEcoutesParSigne m ON e.signeAstrologique = m.signeAstrologique AND e.nombreEcoutes = m.maxEcoutes
         JOIN Tracks t ON e.idTrack = t.idTrack;


/* 4. les 3 artistes les plus écoutés par genre de musique (attention il peut y avoir des exæquo).*/

-- Récupérer le nombre d'écoutes total pour chaque artiste
CREATE OR REPLACE VIEW v4_1 AS
SELECT a.IDARTIST, COUNT(t.IDTRACK) AS Ecoutes
FROM ARTISTS a
         left JOIN PRODUCEDBY pb ON a.IDARTIST = pb.IDARTIST
         left JOIN TRACKS t ON pb.IDALBUM = t.IDALBUM
GROUP BY a.IDARTIST, a.NAME
ORDER BY Ecoutes DESC;

-- Ordonner les artistes par leur popularité par genre
create or replace view v4_2 as
select NAME,
       NVL(NAMEGENRE, 'No Genre')                                    AS Genre,
       RANK() over (PARTITION BY NAMEGENRE ORDER BY Ecoutes, a.NAME) AS rangPop
from ARTISTS a
         join GENREARTIST ga on a.IDARTIST = ga.IDARTIST
         join v4_1 v on a.IDARTIST = v.IDARTIST
group by a.IDARTIST, a.NAME, NAMEGENRE, Ecoutes;


-- On recupère que les 3 populaires pour chaque genre
CREATE OR REPLACE VIEW vue4 as
SELECT NAME, Genre, rangPop
FROM V4_2
WHERE rangPop <= 3
ORDER BY Genre, rangPop, name;



/* 5. pour chaque utilisateur, le pseudo de l'utilisateur et le nom du morceau le plus écouté parmi ceux qui se trouvent
   dans ses playlists. Pour ce morceau, on veut indiquer le chemin dans la playlist (par exemple
   dossier1/dossier11/PlaylistNemard/La quête). */

CREATE OR REPLACE VIEW VUE5 AS
WITH UserTrackListenCount AS (
    SELECT U.idUser,
           U.pseudo,
           PC.idTrack,
           T.name AS trackName,
        COUNT(LD.idTrack) AS listenCount
    FROM
        Users U
            JOIN
        PlaylistContent PC ON U.idUser = PC.idUserPlaylist
            JOIN
        Tracks T ON PC.idTrack = T.idTrack
            LEFT JOIN
        ListeningDate LD ON U.idUser = LD.idUser AND T.idTrack = LD.idTrack
    GROUP BY
        U.idUser, U.pseudo, PC.idTrack, T.name
),
     UserMaxListenTrack AS (
         SELECT idUser,
                pseudo,
                trackName,
                ROW_NUMBER() OVER (PARTITION BY idUser ORDER BY listenCount DESC) AS rn
         FROM UserTrackListenCount
     )
SELECT pseudo,
       trackName AS mostListenedTrack
FROM UserMaxListenTrack
WHERE rn = 1;

/* 6. Pour chaque utilisateur premium, les morceaux partagés avec les utilisateurs amis. */

CREATE OR REPLACE VIEW VUE6 AS
SELECT up.IDUSER, u1.PSEUDO AS "user premium", f.IDUSERFRIEND, u2.PSEUDO AS "user friend", t.idtrack, t.NAME
FROM UserPremium up
         JOIN USERS u1 ON up.IDUSER = u1.IDUSER
         JOIN Friends f ON up.idUser = f.idUserSource
         JOIN Users u2 ON f.IDUSERFRIEND = u2.IDUSER
         JOIN Users u ON f.idUserFriend = u.idUser
         JOIN ShareTrack s ON up.idUser = s.idUserSource
         JOIN Tracks t ON s.idSharedTrack = t.idTrack;


/* 7. le moment de la journée où il y a le plus d'écoutes (matin 6h - 12h, après-midi 12h - 18h, soir 18h - 24h, nuit 0h - 6h).  */

CREATE OR REPLACE VIEW EcouteMatinales AS
SELECT idUser, idTrack, l.DATELISTEN
FROM LISTENINGDATE l
WHERE EXTRACT(HOUR FROM DATELISTEN) > 6
  AND EXTRACT(HOUR FROM DATELISTEN) <= 12;

CREATE OR REPLACE VIEW EcouteAprem AS
SELECT idUser, idTrack, DATELISTEN
FROM LISTENINGDATE
WHERE EXTRACT(HOUR FROM DATELISTEN) > 12
  AND EXTRACT(HOUR FROM DATELISTEN) <= 18;

CREATE OR REPLACE VIEW EcouteSoir AS
SELECT idUser, idTrack, DATELISTEN
FROM LISTENINGDATE
WHERE EXTRACT(HOUR FROM DATELISTEN) > 18
  AND EXTRACT(HOUR FROM DATELISTEN) <= 24;

CREATE OR REPLACE VIEW EcouteNuit AS
SELECT idUser, idTrack, DATELISTEN
FROM LISTENINGDATE
WHERE EXTRACT(HOUR FROM DATELISTEN) > 0
  AND EXTRACT(HOUR FROM DATELISTEN) <= 6;

CREATE OR REPLACE VIEW VUE7 AS
SELECT period, TOTAL_LISTENS
FROM (SELECT 'Matin' AS period, COUNT(*) AS total_listens
      FROM EcouteMatinales
      UNION
      SELECT 'Après-Midi' AS period, COUNT(*) AS total_listens
      FROM EcouteAprem
      UNION
      SELECT 'Soir' AS period, COUNT(*) AS total_listens
      FROM EcouteSoir
      UNION
      SELECT 'Nuit' AS period, COUNT(*) AS total_listens
      FROM EcouteNuit
      order by total_listens desc)
WHERE ROWNUM = 1;


/* 8. pour chaque utilisateur, la note moyenne des évaluations de chacun des morceaux évalués.*/

CREATE OR REPLACE VIEW VUE8 AS
SELECT u.idUser, PSEUDO, ROUND(AVG(e.note), 2) AS "Evaluation moyenne"
FROM Users u
         JOIN Evaluations e ON u.idUser = e.idUser
GROUP BY u.idUser, PSEUDO;


/* 9. pour chaque morceau, la médiane parmi les notes moyennes attribuées par chaque utilisateur (sur le morceau). */

CREATE OR REPLACE VIEW UserTrackMoyenne AS
SELECT e.idTrack, e.idUser, ROUND(AVG(e.note), 2) AS note_Moyenne
FROM Evaluations e
GROUP BY e.idTrack, e.idUser;

CREATE OR REPLACE VIEW VUE9 AS
SELECT utm.idTrack, t.NAME, MEDIAN(utm.note_Moyenne) AS mediane
FROM UserTrackMoyenne utm
         JOIN Tracks t ON utm.idTrack = t.idTrack
GROUP BY utm.idTrack, t.NAME;


/* 10. le morceau qui a le plus grand écart type sur ses notes.*/

-- Vue pour calculer l'écart-type des notes pour chaque morceau
CREATE OR REPLACE VIEW ecart_type_par_morceau AS
SELECT e.IDTRACK,
       STDDEV(e.note) AS ecart_type
FROM Evaluations e
GROUP BY e.idTrack;

-- Vue pour trouver le morceau avec l'écart-type maximal
CREATE OR REPLACE VIEW VUE10 AS
SELECT etpm.IDTRACK,
       t.name,
       etpm.ecart_type
FROM ecart_type_par_morceau etpm
         JOIN TRACKS t on etpm.IDTRACK = t.IDTRACK
WHERE etpm.ecart_type = (SELECT MAX(etpm2.ecart_type) FROM ecart_type_par_morceau etpm2)
  AND ROWNUM = 1;