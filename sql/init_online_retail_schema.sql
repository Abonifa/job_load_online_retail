-- PROCEDURE: retail.init_online_retail_schema()

-- DROP PROCEDURE IF EXISTS retail.init_online_retail_schema();

CREATE OR REPLACE PROCEDURE retail.init_online_retail_schema(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN

    -- ========================================================
    -- 1. TABLE PRINCIPALE
    -- ========================================================
    CREATE TABLE IF NOT EXISTS retail.online_retail (
        invoice_no      VARCHAR(20)     NOT NULL,
        stock_code      VARCHAR(20)     NOT NULL,
        description     VARCHAR(500)    NOT NULL,
        quantity        INTEGER         NOT NULL,
        invoice_date    TIMESTAMP       NOT NULL,
        unit_price      DECIMAL(10,2)   NOT NULL,
        customer_id     VARCHAR(20)     NOT NULL,
        country         VARCHAR(100)    NOT NULL
    );
    RAISE NOTICE 'TABLE retail.online_retail : OK';

    -- ========================================================
    -- 2. TABLE DE REJET
    -- ========================================================
    CREATE TABLE IF NOT EXISTS retail.online_retail_rejet (
        -- Colonnes source
        invoice_no      VARCHAR(20),
        stock_code      VARCHAR(20),
        description     VARCHAR(500),
        quantity        INTEGER,
        invoice_date    TIMESTAMP,
        unit_price      DECIMAL(10,2),
        customer_id     VARCHAR(20),
        country         VARCHAR(100),
        -- Colonnes d'enrichissement rejet
        code_erreur     VARCHAR(50)     NOT NULL,
        message_erreur  VARCHAR(500)    NOT NULL,
        date_rejet      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
        nom_job         VARCHAR(200)    NOT NULL
        --numero_ligne    INTEGER         NOT NULL
    );
    RAISE NOTICE 'TABLE retail.online_retail_rejet : OK';

    -- ========================================================
    -- 3. TABLE DE SUPERVISION
    -- ========================================================
    CREATE TABLE IF NOT EXISTS retail.job_execution_log (
        id                  SERIAL          PRIMARY KEY,
        nom_job             VARCHAR(200)    NOT NULL,
        version_job         VARCHAR(20),
        date_debut          TIMESTAMP       NOT NULL,
        date_fin            TIMESTAMP,
        --duree_secondes      INTEGER,
        nb_lignes_lues      INTEGER         DEFAULT 0,
        nb_lignes_ok        INTEGER         DEFAULT 0,
        nb_lignes_rejetees  INTEGER         DEFAULT 0,
        --taux_rejet          DECIMAL(5,2),
        statut              VARCHAR(20),    -- SUCCES / ECHEC / PARTIEL
        message_fin         VARCHAR(500)
    );
    RAISE NOTICE 'TABLE retail.job_execution_log : OK';

    RAISE NOTICE '=====================================';
    RAISE NOTICE 'SCHEMA retail : INITIALISATION OK';
    RAISE NOTICE '=====================================';

END;
$BODY$;
ALTER PROCEDURE retail.init_online_retail_schema()
    OWNER TO postgres;


