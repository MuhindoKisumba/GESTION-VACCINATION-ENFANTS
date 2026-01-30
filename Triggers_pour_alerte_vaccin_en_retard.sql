--Table des alertes vaccinales
CREATE TABLE alerte_vaccination (
    id_alerte SERIAL PRIMARY KEY,
    id_enfant INT REFERENCES enfant(id_enfant),
    id_vaccin INT REFERENCES vaccin(id_vaccin),
    dose_numero INT NOT NULL,
    date_prevue DATE NOT NULL,
    jours_retard INT NOT NULL,
    statut VARCHAR(30) DEFAULT 'NON_LUE',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_enfant, id_vaccin, dose_numero)
);

--Fonction : calcul et génération des alertes
CREATE OR REPLACE FUNCTION fn_verifier_vaccin_retard()
RETURNS VOID AS $$
DECLARE
    rec RECORD;
    date_prevue DATE;
    retard INT;
BEGIN
    FOR rec IN
        SELECT
            e.id_enfant,
            e.date_naissance,
            cv.id_vaccin,
            cv.dose_numero,
            cv.age_prevu_mois
        FROM enfant e
        CROSS JOIN calendrier_vaccinal cv
    LOOP
        -- Calcul de la date prévue
        date_prevue := rec.date_naissance + (rec.age_prevu_mois || ' months')::INTERVAL;

        -- Vérifier si la dose a déjà été administrée
        IF NOT EXISTS (
            SELECT 1
            FROM vaccination v
            WHERE v.id_enfant = rec.id_enfant
              AND v.id_vaccin = rec.id_vaccin
              AND v.dose_numero = rec.dose_numero
        ) THEN
            IF date_prevue < CURRENT_DATE THEN
                retard := CURRENT_DATE - date_prevue;

                INSERT INTO alerte_vaccination (
                    id_enfant,
                    id_vaccin,
                    dose_numero,
                    date_prevue,
                    jours_retard
                )
                VALUES (
                    rec.id_enfant,
                    rec.id_vaccin,
                    rec.dose_numero,
                    date_prevue,
                    retard
                )
                ON CONFLICT DO NOTHING;
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--Trigger automatique après insertion d’un enfant

CREATE OR REPLACE FUNCTION trg_apres_insertion_enfant()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM fn_verifier_vaccin_retard();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_enfant
AFTER INSERT ON enfant
FOR EACH ROW
EXECUTE FUNCTION trg_apres_insertion_enfant();

--Trigger après vaccination (nettoyage des alertes)

CREATE OR REPLACE FUNCTION trg_apres_vaccination()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM alerte_vaccination
    WHERE id_enfant = NEW.id_enfant
      AND id_vaccin = NEW.id_vaccin
      AND dose_numero = NEW.dose_numero;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_vaccination
AFTER INSERT ON vaccination
FOR EACH ROW
EXECUTE FUNCTION trg_apres_vaccination();

--Vue pratique : vaccins en retard

CREATE VIEW vue_vaccins_en_retard AS
SELECT
    a.id_alerte,
    e.nom || ' ' || e.prenom AS enfant,
    v.nom AS vaccin,
    a.dose_numero,
    a.date_prevue,
    a.jours_retard,
    a.statut
FROM alerte_vaccination a
JOIN enfant e ON e.id_enfant = a.id_enfant
JOIN vaccin v ON v.id_vaccin = a.id_vaccin;




















