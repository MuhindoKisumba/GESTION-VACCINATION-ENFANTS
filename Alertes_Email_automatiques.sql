--Pré-requis PostgreSQL (à faire une seule fois)

-- Extension Python
CREATE EXTENSION IF NOT EXISTS plpython3u;

-- Planificateur CRON
CREATE EXTENSION IF NOT EXISTS pg_cron;

--Table de configuration Email (sécurisée)

CREATE TABLE config_email (
    id SERIAL PRIMARY KEY,
    smtp_host VARCHAR(150),
    smtp_port INT,
    email_expediteur VARCHAR(150),
    mot_de_passe TEXT,
    actif BOOLEAN DEFAULT TRUE
);

INSERT INTO config_email (
    smtp_host, smtp_port, email_expediteur, mot_de_passe
)
VALUES (
    'smtp.gmail.com',
    587,
    'centre.sante@gmail.com',
    'MOT_DE_PASSE_APPLICATION'
);

--Fonction d’envoi Email (PL/Python)

CREATE OR REPLACE FUNCTION envoyer_email_alerte(
    email_destinataire TEXT,
    sujet TEXT,
    message TEXT
)
RETURNS VOID AS $$
import smtplib
from email.mime.text import MIMEText

conf = plpy.execute("""
    SELECT smtp_host, smtp_port, email_expediteur, mot_de_passe
    FROM config_email
    WHERE actif = true
    LIMIT 1
""")[0]

msg = MIMEText(message)
msg['Subject'] = sujet
msg['From'] = conf['email_expediteur']
msg['To'] = email_destinataire

server = smtplib.SMTP(conf['smtp_host'], conf['smtp_port'])
server.starttls()
server.login(conf['email_expediteur'], conf['mot_de_passe'])
server.send_message(msg)
server.quit()
$$ LANGUAGE plpython3u;


--Fonction automatique d’alerte vaccins en retard

CREATE OR REPLACE FUNCTION alerte_vaccin_retard_email()
RETURNS VOID AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT
            p.telephone AS email, -- remplace par email si tu ajoutes colonne
            e.nom || ' ' || e.prenom AS enfant,
            v.nom AS vaccin,
            a.jours_retard
        FROM alerte_vaccination a
        JOIN enfant e ON e.id_enfant = a.id_enfant
        JOIN parent p ON p.id_parent = e.id_parent
        JOIN vaccin v ON v.id_vaccin = a.id_vaccin
        WHERE a.statut = 'NON_LUE'
    LOOP
        PERFORM envoyer_email_alerte(
            'parent@email.com',
            'Vaccin en retard',
            'Bonjour,

Le vaccin ' || rec.vaccin || ' pour l’enfant ' || rec.enfant ||
            ' accuse un retard de ' || rec.jours_retard || ' jours.

Merci de vous présenter au centre de santé.

— Service Vaccination'
        );

        UPDATE alerte_vaccination
        SET statut = 'EMAIL_ENVOYE'
        WHERE id_enfant = rec.id_enfant;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--Planification automatique (CRON quotidien)

SELECT cron.schedule(
    'alerte-vaccins-email',
    '0 8 * * *',
    $$CALL alerte_vaccin_retard_email();$$
);

