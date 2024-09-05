CREATE TABLE TEMP_ALBUMS
(
    idAlbum       CHAR(22),
    name          VARCHAR(50)   NOT NULL,
    nameType      VARCHAR(50)   NOT NULL,
    label         VARCHAR(50)   NOT NULL,
    yearOfRelease DECIMAL(4, 0) NOT NULL,
    idCopyright   VARCHAR(50),
    copyright     VARCHAR(50),
    idArtist      CHAR(22),
    ArtistName    VARCHAR(50)
);

CREATE TABLE TEMP_ARTISTS
(
    idArtist     CHAR(22) NOT NULL,
    name         VARCHAR(50),
    popularity   INT      NOT NULL,
    followers    INT      NOT NULL,
    nameGenre    VARCHAR(50),
    nameAward    VARCHAR(50),
    nameCategory VARCHAR(50),
    artistYear   INT
);

CREATE TABLE TEMP_Evaluation
(
    idUser    INT,
    pseudo    VARCHAR(50),
    idTrack   CHAR(22),
    nameTrack VARCHAR(50),
    note      INT NOT NULL
);

CREATE TABLE TEMP_Friends
(
    idUserPremium INT,
    pseudo        VARCHAR(50),
    name          VARCHAR(50),
    surname       VARCHAR(50),
    idUserFriend  INT,
    friendName    VARCHAR(50),
    friendSurname VARCHAR(50)
);

CREATE TABLE TEMP_LIKES
(
    idUser    INT,
    pseudo    VARCHAR(50),
    idTrack   CHAR(22),
    nameTrack VARCHAR(50),
    dateLike  DATE
);

CREATE TABLE TEMP_PLAYLIST
(
    idUser            INT,
    pseudo            VARCHAR(50),
    name              VARCHAR(50),
    type              VARCHAR(50),
    nameParentElement VARCHAR(50),
    idTrack           CHAR(22),
    nameTrack         VARCHAR(50),
    "ORDER"           INT
);

CREATE TABLE TEMP_SHARE
(
    idUser       INT,
    pseudo       VARCHAR(50),
    name         VARCHAR(50),
    surname      VARCHAR(50),
    idUserShare  INT,
    pseudoShare  VARCHAR(50),
    nameShare    VARCHAR(50),
    surnameShare VARCHAR(50),
    idTrack      CHAR(22),
    nameTrack    VARCHAR(50)
);

CREATE TABLE TEMP_TRACKS
(
    idTrack          CHAR(22),
    name             VARCHAR(50),
    popularity       INT         NOT NULL,
    danceability     REAL,
    energy           REAL,
    keySignature     INT,
    loudness         REAL,
    "MODE"           NUMBER(1),
    speechiness      REAL,
    acoustiness      REAL,
    instrumentalness REAL,
    liveness         REAL,
    valence          REAL,
    tempo            REAL,
    durationMs       INT,
    idAlbum          CHAR(22),
    albumName        VARCHAR(50) NOT NULL,
    idArtist         CHAR(22)    NOT NULL,
    artistName       VARCHAR(50),
    idUser           INT,
    pseudo           VARCHAR(50),
    dateListen       DATE
);

CREATE TABLE TEMP_USERS
(
    idUser           INT,
    pseudo           VARCHAR(50),
    genderName       CHAR(1),
    dateOfBirth      DATE,
    name             VARCHAR(50),
    surname          VARCHAR(50),
    idCurrentTrack   CHAR(22),
    currentNameTrack VARCHAR(50),
    timePlaying      INT,
    idArtistFollow   CHAR(22),
    artistNameFollow VARCHAR(50)
);

CREATE TABLE TEMP_USERS_BLOCKED
(
    idUserPremium INT,
    pseudoPremium        VARCHAR(50),
    namePremium          VARCHAR(50),
    surnamePremium       VARCHAR(50),
    idUserBlocked INT,
    nameBlocked         VARCHAR(50),
    surnameBlocked       VARCHAR(50)
)