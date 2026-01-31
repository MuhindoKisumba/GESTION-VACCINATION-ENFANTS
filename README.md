# Système de Gestion de la Vaccination des Enfants

## Description
Ce projet est une **base de données PostgreSQL professionnelle** destinée à la **gestion complète de la vaccination des enfants** dans un centre de santé, hôpital ou programme national de vaccination.

Le système permet :
- l’enregistrement des enfants et des parents
- la gestion des vaccins et du calendrier vaccinal
- le suivi des vaccinations effectuées
- la détection automatique des vaccins en retard
- l’envoi **d’alertes email automatiques** aux responsables / parents

---

## Architecture du système

PostgreSQL
│
├── Tables de base
│ ├── enfant
│ ├── parent
│ ├── vaccin
│ ├── calendrier_vaccinal
│ ├── vaccination
│ ├── centre_sante
│ └── agent_sante
│
├── Automatisation
│ ├── Triggers PostgreSQL
│ ├── Fonctions PL/pgSQL
│ ├── Fonctions PL/Python
│ └── pg_cron
│
└── Alertes
├── alerte_vaccination
└── Envoi Email SMTP


---

## Technologies utilisées

- **PostgreSQL 13+**
- **PL/pgSQL**
- **PL/Python (plpython3u)**
- **pg_cron**
- **SMTP (Gmail / Outlook / Serveur local)**

---

## Structure de la base de données

### Tables principales
| Table | Description |
|-----|------------|
| `parent` | Informations des parents |
| `enfant` | Données des enfants |
| `vaccin` | Liste des vaccins |
| `calendrier_vaccinal` | Âge recommandé et doses |
| `vaccination` | Historique des vaccinations |
| `centre_sante` | Centres de santé |
| `agent_sante` | Agents vaccinateurs |
| `alerte_vaccination` | Vaccins en retard |

---

## Gestion des vaccins en retard

### Principe
1. Le système calcule la **date prévue du vaccin**
2. Compare avec la date actuelle
3. Vérifie si la dose a été administrée
4. Crée une **alerte automatique** si retard

---

## Alertes Email automatiques

### Fonctionnalités
- Envoi d’email automatique pour chaque vaccin en retard
- Aucun doublon d’alerte
- Statut de suivi (`NON_LUE`, `EMAIL_ENVOYE`)
- Planification quotidienne automatique

### Planification CRON
```sql
SELECT cron.schedule(
    'alerte-vaccins-email',
    '0 8 * * *',
    $$CALL alerte_vaccin_retard_email();$$
);

Sécurité
--------

Utilisation de mots de passe SMTP applicatifs

Séparation configuration email / logique métier

Contraintes SQL (CHECK, UNIQUE, FOREIGN KEY)

Suppression automatique des alertes après vaccination

Vues utiles
-----------

vue_vaccins_en_retard

Rapports par centre de santé

Statistiques de couverture vaccinale

Déploiement
---------------
Prérequis
sudo apt install postgresql postgresql-contrib

Extensions PostgreSQL
CREATE EXTENSION plpython3u;
CREATE EXTENSION pg_cron;

Évolutions futures

Alertes SMS / WhatsApp

Dashboard Web (FastAPI + React)

Rapports PDF / Excel

Version nationale (PNV)

Gestion des rôles utilisateurs

Application mobile Android

Auteur

Muhindo Kisumba Abdiel
Cybersecurity & Bases de Données
Spécialité : PostgreSQL • Automatisation • Systèmes de gestion
