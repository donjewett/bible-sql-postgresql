/* *************************************************************************
Bible Database: PostgreSQL, by Don Jewett
https://github.com/donjewett/bible-sql-postgresql

bible-010-schema.sql
Version: 2025.10.31

************************************************************************* */

-- -------------------------------------------------------------------------
-- Languages
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Languages (
	Id char(3) NOT NULL,
	Name varchar(16) NOT NULL,
	HtmlCode char(2) NOT NULL,
	IsAncient boolean NOT NULL DEFAULT false,
 	CONSTRAINT PK_Language PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- Canons
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Canons (
	Id int NOT NULL,
	Code char(2) NOT NULL,
	Name varchar(24) NOT NULL,
	LanguageId varchar(3) NOT NULL,
	CONSTRAINT PK_Canons PRIMARY KEY (Id),
	CONSTRAINT FK_Canons_Languages FOREIGN KEY (LanguageId) REFERENCES Languages (Id)
);

-- -------------------------------------------------------------------------
-- Sections
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Sections (
	Id int NOT NULL,
	Name varchar(16) NOT NULL,
	CanonId int NOT NULL,
	CONSTRAINT PK_Sections PRIMARY KEY (Id),
	CONSTRAINT FK_Sections_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id)
);

-- -------------------------------------------------------------------------
-- Books
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Books (
	Id int NOT NULL,
	Code varchar(5) NOT NULL,
	Abbrev varchar(5) NOT NULL,
	Name varchar(16) NOT NULL,
	Book smallint NOT NULL,
	CanonId int NOT NULL, -- denormalized
	SectionId int NOT NULL,
	IsSectionEnd boolean NOT NULL DEFAULT false,
	ChapterCount smallint NOT NULL,
	OsisCode varchar(6) NOT NULL,
	Paratext char(3) NOT NULL,
	CONSTRAINT PK_Books PRIMARY KEY (Id),
	CONSTRAINT FK_Books_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_Books_Sections FOREIGN KEY (SectionId) REFERENCES Sections (Id)
);

-- -------------------------------------------------------------------------
-- BookNames
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BookNames (
	Name varchar(64) NOT NULL,
	BookId int NOT NULL,
	CONSTRAINT PK_BookNames PRIMARY KEY (Name),
	CONSTRAINT FK_BookNames_Books FOREIGN KEY (BookId) REFERENCES Books (Id)
);

-- -------------------------------------------------------------------------
-- Chapters
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Chapters (
	Id int NOT NULL,
	Code varchar(7) NOT NULL,
	Reference varchar(8) NOT NULL,
	Chapter smallint NOT NULL,
	BookId int NOT NULL,
	IsBookEnd boolean NOT NULL DEFAULT false,
	VerseCount int NOT NULL,
	CONSTRAINT PK_Chapters PRIMARY KEY (Id),
	CONSTRAINT FK_Chapters_Books FOREIGN KEY (BookId) REFERENCES Books (Id)
);

-- -------------------------------------------------------------------------
-- Verses
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Verses (
	Id int NOT NULL,
	Code varchar(16) NOT NULL,
	OsisCode varchar(12) NOT NULL,
	Reference varchar(10) NOT NULL,
	CanonId int NOT NULL, --denormalized
	SectionId int NOT NULL, --denormalized
	BookId int NOT NULL, --denormalized
	ChapterId int NOT NULL,
	IsChapterEnd boolean NOT NULL DEFAULT false,
	Book smallint NOT NULL, --denormalized
	Chapter smallint NOT NULL, --denormalized
	Verse smallint NOT NULL,
	CONSTRAINT PK_Verses PRIMARY KEY (Id),
	CONSTRAINT FK_Verses_Books FOREIGN KEY (BookId) REFERENCES Books (Id),
	CONSTRAINT FK_Verses_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters (Id),
	CONSTRAINT FK_Verses_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_Verses_Sections FOREIGN KEY (SectionId) REFERENCES Sections (Id)
);

-- -------------------------------------------------------------------------
-- GreekTextForms
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS GreekTextForms (
	Id char(3) NOT NULL,
	Name varchar(48) NOT NULL,
	ParentId char(3) NULL,
	CONSTRAINT PK_GreekTextForms PRIMARY KEY (Id),
	CONSTRAINT FK_GreekTextForms_GreekTextForms FOREIGN KEY (ParentId) REFERENCES GreekTextForms (Id)
);

-- -------------------------------------------------------------------------
-- HebrewTextForms
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS HebrewTextForms (
	Id char(3) NOT NULL,
	Name varchar(48) NOT NULL,
	ParentId char(3) NULL,
	CONSTRAINT PK_HebrewTextForms PRIMARY KEY (Id),
	CONSTRAINT FK_HebrewTextForms_GHebrewTextForms FOREIGN KEY (ParentId) REFERENCES HebrewTextForms (Id)
);

-- -------------------------------------------------------------------------
-- LicensePermissions
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LicensePermissions (
	Id serial NOT NULL,
	Name varchar(48) NOT NULL,
	Permissiveness int NOT NULL,
	CONSTRAINT PK_LicensePermissions PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- LicenseTypes
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LicenseTypes (
	Id serial NOT NULL,
	Name varchar(64) NOT NULL,
	IsFree boolean NOT NULL DEFAULT false,
	PermissionId int NULL,
	CONSTRAINT PK_LicenseType PRIMARY KEY (Id),
	CONSTRAINT FK_LicenseTypes_LicensePermissions FOREIGN KEY (PermissionId) REFERENCES LicensePermissions (Id)
);

-- -------------------------------------------------------------------------
-- Versions
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Versions (
	Id serial NOT NULL,
	Code varchar(16) NOT NULL,
	Name varchar(64) NOT NULL,
	Subtitle varchar(128) NULL,
	LanguageId char(3) NOT NULL,
	YearPublished smallint NOT NULL,
	HebrewFormId char(3) NULL,
	GreekFormId char(3) NULL,
	ParentId int NULL,
	LicenseTypeId int NULL,
	ReadingLevel decimal(4, 2) NULL,
	CONSTRAINT PK_Versions PRIMARY KEY (Id),
	CONSTRAINT FK_Versions_Languages FOREIGN KEY (LanguageId) REFERENCES Languages (Id),
	CONSTRAINT FK_Versions_Versions FOREIGN KEY (ParentId) REFERENCES Versions (Id),
	CONSTRAINT FK_Versions_GreekTextForms FOREIGN KEY (GreekFormId) REFERENCES GreekTextForms (Id),
	CONSTRAINT FK_Versions_HebrewTextForms FOREIGN KEY (HebrewFormId) REFERENCES HebrewTextForms (Id),
	CONSTRAINT FK_Versions_LicenseTypes FOREIGN KEY (LicenseTypeId) REFERENCES LicenseTypes (Id)
);

-- -------------------------------------------------------------------------
-- Revisions
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Revisions (
	Id serial NOT NULL,
	Code varchar(16) NOT NULL,
	VersionId int NOT NULL,
	YearPublished smallint NOT NULL,
	Subtitle varchar(128) NULL,
	CONSTRAINT PK_Revisions PRIMARY KEY (Id),
	CONSTRAINT FK_Revisions_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id)
);

-- -------------------------------------------------------------------------
-- Sites
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Sites (
	Id serial NOT NULL,
	Name varchar(64) NOT NULL,
	Url varchar(255) NULL,
	CONSTRAINT PK_Sites PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- ResourceTypes
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ResourceTypes (
	Id varchar(8) NOT NULL,
	Name varchar(64) NOT NULL,
	CONSTRAINT PK_ResourceTypes PRIMARY KEY (Id)
);

-- -------------------------------------------------------------------------
-- Resources
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Resources (
	Id serial NOT NULL,
	ResourceTypeId varchar(8) NOT NULL,
	VersionId int NOT NULL,
	RevisionId int NULL,
	Url varchar(255) NULL,
	IsOfficial boolean NOT NULL DEFAULT false,
	SiteId int NULL,
	CONSTRAINT PK_Resources PRIMARY KEY (Id),
	CONSTRAINT FK_Resources_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_Resources_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_Resources_ResourceTypes FOREIGN KEY (ResourceTypeId) REFERENCES ResourceTypes (Id),
	CONSTRAINT FK_Resources_Sites FOREIGN KEY (SiteId) REFERENCES Sites (Id)
);

-- -------------------------------------------------------------------------
-- Bibles
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Bibles (
	Id serial NOT NULL,
	Code varchar(16) NOT NULL,
	Name varchar(64) NOT NULL,
	Subtitle varchar(128) NULL,
	VersionId int NOT NULL,
	RevisionId int NULL,
	YearPublished smallint NULL,
	TextFormat varchar(6) NOT NULL DEFAULT ('txt'),
	SourceId int NULL,
	CONSTRAINT PK_Bibles PRIMARY KEY (Id),
	CONSTRAINT FK_Bibles_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_Bibles_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_Bibles_Resources FOREIGN KEY (SourceId) REFERENCES Resources (Id)
);

-- -------------------------------------------------------------------------
-- BibleVerses
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BibleVerses (
	Id serial NOT NULL,
	BibleId int NOT NULL,
	VerseId int NOT NULL,
	Markup text NOT NULL,
	PreMarkup varchar(255) NULL,
	PostMarkup varchar(255) NULL,
	Notes varchar(255) NULL,
	CONSTRAINT PK_BibleVerses PRIMARY KEY (Id),
	CONSTRAINT FK_BibleVerses_Bibles FOREIGN KEY (BibleId) REFERENCES Bibles (Id),
	CONSTRAINT FK_BibleVerses_Verses FOREIGN KEY (VerseId) REFERENCES Verses (Id)
);

CREATE UNIQUE INDEX IF NOT EXISTS UQ_BibleVerses_Version_Verse ON BibleVerses
(
	BibleId ASC,
	VerseId ASC
);

-- -------------------------------------------------------------------------
-- VersionNotes
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VersionNotes (
	Id serial NOT NULL,
	VersionId int NOT NULL,
	RevisionId int NULL,
	BibleId int NULL,
	CanonId int NULL,
	BookId int NULL,
	ChapterId int NULL,
	VerseId int NULL,
	Note text NOT NULL,
	Label varchar(64) NULL,
	Ranking int NOT NULL DEFAULT 0,
	CONSTRAINT PK_VersionNotes PRIMARY KEY (Id),
	CONSTRAINT FK_VersionNotes_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_VersionNotes_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_VersionNotes_Bibles FOREIGN KEY (BibleId) REFERENCES Bibles (Id),
	CONSTRAINT FK_VersionNotes_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_VersionNotes_Books FOREIGN KEY (CanonId) REFERENCES Books (Id),
	CONSTRAINT FK_VersionNotes_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters (Id),
	CONSTRAINT FK_VersionNotes_Verses FOREIGN KEY (VerseId) REFERENCES Verses (Id)
);
