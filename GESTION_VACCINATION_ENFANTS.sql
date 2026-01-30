-- BASE DE DONNÉES
CREATE DATABASE gestion_vaccination_enfants;
\c gestion_vaccination_enfants;

-- TABLE : CENTRE_DE_SANTE
CREATE TABLE centre_sante (
    id_centre SERIAL PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    adresse TEXT,
    province VARCHAR(100),
    telephone VARCHAR(20),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE : AGENT_SANTE
CREATE TABLE agent_sante (
    id_agent SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    postnom VARCHAR(100),
    prenom VARCHAR(100),
    fonction VARCHAR(100),
    telephone VARCHAR(20),
    id_centre INT REFERENCES centre_sante(id_centre),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE : PARENT
CREATE TABLE parent (
    id_parent SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    postnom VARCHAR(100),
    prenom VARCHAR(100),
    sexe CHAR(1) CHECK (sexe IN ('M','F')),
    telephone VARCHAR(20),
    adresse TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- TABLE : ENFANT
CREATE TABLE enfant (
    id_enfant SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    postnom VARCHAR(100),
    prenom VARCHAR(100),
    sexe CHAR(1) CHECK (sexe IN ('M','F')),
    date_naissance DATE NOT NULL,
    lieu_naissance VARCHAR(150),
    id_parent INT REFERENCES parent(id_parent),
    id_centre INT REFERENCES centre_sante(id_centre),
    date_enregistrement TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE : VACCIN
CREATE TABLE vaccin (
    id_vaccin SERIAL PRIMARY KEY,
    nom VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    age_recommande_mois INT NOT NULL,
    nombre_doses INT NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLE : CALENDRIER_VACCINAL
CREATE TABLE calendrier_vaccinal (
    id_calendrier SERIAL PRIMARY KEY,
    id_vaccin INT REFERENCES vaccin(id_vaccin),
    dose_numero INT NOT NULL,
    age_prevu_mois INT NOT NULL,
    UNIQUE (id_vaccin, dose_numero)
);

-- TABLE : VACCINATION
CREATE TABLE vaccination (
    id_vaccination SERIAL PRIMARY KEY,
    id_enfant INT REFERENCES enfant(id_enfant),
    id_vaccin INT REFERENCES vaccin(id_vaccin),
    dose_numero INT NOT NULL,
    date_vaccination DATE NOT NULL,
    id_agent INT REFERENCES agent_sante(id_agent),
    observation TEXT,
    UNIQUE (id_enfant, id_vaccin, dose_numero)
);

-- TABLE : RENDEZ_VOUS_VACCINATION
CREATE TABLE rendez_vous_vaccination (
    id_rendez_vous SERIAL PRIMARY KEY,
    id_enfant INT REFERENCES enfant(id_enfant),
    id_vaccin INT REFERENCES vaccin(id_vaccin),
    dose_numero INT NOT NULL,
    date_prevue DATE NOT NULL,
    statut VARCHAR(30) DEFAULT 'EN_ATTENTE',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INDEX POUR PERFORMANCE
CREATE INDEX idx_enfant_parent ON enfant(id_parent);
CREATE INDEX idx_vaccination_enfant ON vaccination(id_enfant);
CREATE INDEX idx_rendez_vous_enfant ON rendez_vous_vaccination(id_enfant);

