# job_load_online_retail

**Projet Data Engineering — Talend TOS | PostgreSQL | UCI Online Retail**

### Auteur : GBEYA ANNICET

Projet réalisé dans le cadre d'un apprentissage avancé de Talend TOS et du Data Engineering.

---

## Description

Job Talend TOS réalisant le chargement complet du dataset **UCI Online Retail** (541 909 transactions) depuis un fichier CSV vers une base de données PostgreSQL, avec :

- Validation et routage des données (flux OK / flux rejet)
- Enrichissement des lignes rejetées (code erreur, message métier, horodatage)
- Supervision de l'exécution via table de log
- Gestion des erreurs techniques (tDie, tLogCatcher)
- Connexion partagée et variables de contexte (portabilité multi-environnements)

---

## Dataset — UCI Online Retail

Le dataset Online Retail contient l'ensemble des transactions réalisées entre le 01/12/2010 et le 09/12/2011 pour un retailer en ligne basé au Royaume-Uni, spécialisé dans les cadeaux.

| Caractéristique | Valeur |
|---|---|
| **Nombre de lignes** | 541 909 |
| **Nombre de colonnes** | 8 |
| **Période** | 01/12/2010 — 09/12/2011 |
| **Source** | UCI Machine Learning Repository |
| **Licence** | CC BY 4.0 |

### Colonnes du dataset

| Colonne | Type | Description |
|---|---|---|
| `InvoiceNo` | Nominal | Numéro de facture à 6 chiffres. Commence par `c` si annulation |
| `StockCode` | Nominal | Code produit unique à 5 chiffres |
| `Description` | Nominal | Nom du produit |
| `Quantity` | Integer | Quantité par transaction. Négative si annulation |
| `InvoiceDate` | Date | Date et heure de la transaction |
| `UnitPrice` | Decimal | Prix unitaire en livres sterling (£) |
| `CustomerID` | Nominal | Identifiant client unique à 5 chiffres |
| `Country` | Nominal | Pays de résidence du client |

---

## Stack technique

| Composant | Technologie |
|---|---|
| **ETL** | Talend Open Studio for Data Integration |
| **Base de données** | PostgreSQL |
| **Dataset source** | [UCI Online Retail](https://archive.ics.uci.edu/dataset/352/online%2Bretail?) |
| **Langage** | Java (Talend), SQL |

---

## Prérequis

- Talend TOS 7.3.1 ou supérieur
- PostgreSQL 9.5 ou supérieur
- Dataset `Online Retail.csv` disponible localement (téléchargeable ici https://archive.ics.uci.edu/dataset/352/online%2Bretail?)

---

## Structure de la base de données

### Initialisation

Lancer la procédure de création des tables :

```sql
CALL retail.init_online_retail_schema();
```

> Script complet disponible dans `sql/init_online_retail_schema.sql`

### Tables créées

#### `retail.online_retail` — Table principale

Contient les **397 924 transactions valides** du dataset.

**Aperçu des 10 premières lignes :**

*Voir captures d'écran dans le dossier `/screenshots`*

#### `retail.online_retail_rejet` — Table de rejet

Contient les **143 985 lignes rejetées** enrichies.

**Aperçu des 10 premières lignes :**

*Voir captures d'écran dans le dossier `/screenshots`*

#### `retail.job_execution_log` — Table de supervision

**Aperçu :**

*Voir captures d'écran dans le dossier `/screenshots`*

---

## Architecture du job

```
SUBJOB 1 — Initialisation
  tPrejob
    → tDBConnection  (connexion partagée)
      → tDie         (si connexion impossible)
    → tSetGlobalVar  (DEBUT_EXECUTION, STATUT_JOB)

SUBJOB 2 — Chargement principal
  tFileExist
    → tDie           (si fichier introuvable)
    → tFileInputDelimited (lecture CSV)
        → tMap_1 — Validation_routage
            → [out_ok]      → tDBOutput_1 (retail.online_retail)
                             → tDBCommit_1
            → [out_rejects] → tMap_2 — Enrichissement_rejet
                                → tDBOutput_2 (retail.online_retail_rejet)
                                  → tDBCommit_2
                                → tLogRow (console)
  tLogCatcher → tLogRow (erreurs techniques)

SUBJOB 3 — Supervision
  tPostgresqlRow → INSERT retail.job_execution_log
    → tDBCommit_3

SUBJOB 4 — Finalisation
  tPostjob → tDBClose
```

*Voir captures d'écran dans le dossier `/screenshots`*

---

## Règles de validation / rejet

| Code erreur | Condition | Message métier |
|---|---|---|
| `ERR_CUSTOMER_ID_NULL` | `customer_id` null ou vide | Client non identifié |
| `ERR_DESCRIPTION_NULL` | `description` null ou vide | Description produit manquante |
| `ERR_QUANTITY_INVALIDE` | `quantity` null ou négative | Quantité négative — annulation détectée |
| `ERR_UNIT_PRICE_INVALIDE` | `unit_price` null ou négatif | Prix unitaire invalide |

---

## Variables de contexte

> Voir `/context/ctx_online_retail.properties.template`

---

## Résultats d'exécution

| Métrique | Valeur |
|---|---|
| **Lignes lues** | 541 909 |
| **Lignes OK** | 397 924 (73,4%) |
| **Lignes rejetées** | 143 985 (26,6%) |
| `ERR_CUSTOMER_ID_NULL` | 135 080 |
| `ERR_QUANTITY_INVALIDE` | 8 905 |

---

## Structure du projet

```
job_load_online_retail/
├── README.md
├── sql/
│   └── init_online_retail_schema.sql
├── context/
│   └── ctx_online_retail.properties.template
└── screenshots/
    ├── canvas_job.png
    ├── tmap1_validation.png
    ├── tmap2_enrichissement.png
    ├── online_retail_apercu.png
    ├── online_retail_rejet_apercu.png
    ├── job_execution_log_apercu.png
```

---

