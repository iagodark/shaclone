CREATE TABLE IF NOT EXISTS "fabricante" (
	-- Informações sobre os fabricantes responsáveis pela produção de embalagens.
	"id_cnpj_fabricante" char(14) NOT NULL,  -- CNPJ do fabricante.
	"razao_social" varchar(100) NOT NULL, -- Razão social do fabricante.
	"logradouro" varchar(200) NOT NULL, -- Endereço do fabricante.
	"numero" varchar(10) NOT NULL,  -- Número do endereço.
	"complemento" varchar(50), -- Complemento do endereço.
	"bairro" varchar(50) NOT NULL, -- Bairro do endereço.
	"cidade" varchar(50) NOT NULL, -- Cidade do fabricante.
	"estado" varchar(2) NOT NULL, -- Estado do fabricante.
	"cep" char(8) NOT NULL, -- CEP do fabricante.
	"email" varchar(254), -- E-mail de contato.
	"telefone" varchar(20),  -- Telefone de contato.
	"descricao" varchar(255), -- Descrição adicional.
	PRIMARY KEY ("id_cnpj_fabricante") -- Define id_cnpj_fabricante como chave primária para identificar o fabricante.
);

CREATE TABLE IF NOT EXISTS "lote_embalagem" ( 
	 -- Registro de lotes de embalagens produzidas, com informações como fabricante, peso, tipo de material e status.
	"codigo_lote" varchar(50) NOT NULL UNIQUE, -- Código único do lote.
	"fabricante" varchar(14) NOT NULL, -- CNPJ do fabricante responsável pelo lote.
	"data_producao" date NOT NULL, -- Data de produção do lote.
	"data_validade" date, -- Data de validade, se aplicável.
	"tipo_material" varchar(50) CHECK(tipo_material in ('plastico', 'papel', 'vidro', 'metal', 'aluminio')), -- Tipo de material do lote.
	"peso_toneladas" numeric(10, 2) NOT NULL,  -- Peso total do lote em toneladas.
	"status_lote" varchar(10) CHECK(status_lote in ('armazenado', 'enviado')),  -- Status logístico do lote.
	"status_reciclagem" VARCHAR(10) CHECK (status_reciclagem IN ('pendente', 'concluido')), -- Status da reciclagem do lote.
	"meta_reciclagem_toneladas" NUMERIC(10, 2) 
        GENERATED ALWAYS AS ("peso_toneladas" * 0.22) STORED, -- Meta de reciclagem (22% do peso total).
	"descricao" varchar(255), -- Descrição adicional sobre o lote.
	PRIMARY KEY ("codigo_lote") -- Define "codigo_lote" como chave primária para identificar o lote.
);

CREATE TABLE IF NOT EXISTS "nota_fiscal" (
	-- Registro de notas fiscais, relacionadas a transações de lotes de embalagens.
	"id_nf" varchar(50) NOT NULL UNIQUE, -- Identificador único da nota fiscal.
	"ncm" char(8) NOT NULL, -- Código NCM (Nomenclatura Comum do Mercosul) do produto.
	"emissor" char(14) NOT NULL, -- CNPJ do emissor da nota, no caso o fabricante do lote.
	"destinatario" varchar(14), --CNPJ do destinatário da nota.
	"lote" varchar(50) NOT NULL, -- Código do lote associado à nota fiscal.
	"descricao" varchar(300) NOT NULL, -- Descrição detalhada dos itens na nota fiscal.
	"unidade" varchar(20) NOT NULL, -- Unidade de medida dos itens(Toneladas).
	"quantidade" numeric(10,2) NOT NULL, -- Quantidade dos itens.
	"cfop" char(4) DEFAULT '5101', --Código Fiscal de Operações e Prestações padrão.
	"cst" char(3), -- Código de Situação Tributária.
	"icms" numeric(5,2) DEFAULT '21', -- Alíquota padrão de ICMS.
	"pis" numeric(10,2) DEFAULT '1.65', -- Alíquota padrão de PIS.
	"cofins" numeric(10,2) DEFAULT '7.6',-- Alíquota padrão de COFINS.
	"valor_unitario_nf" numeric(15,2), -- Valor unitário dos itens na nota fiscal.
	"valor_total" numeric 
		GENERATED ALWAYS AS ("valor_unitario_nf" * "quantidade" * (1 + ("icms" + "pis" + "cofins") / 100)) STORED, -- Valor total da nota fiscal em reais incluindo tributos.
	PRIMARY KEY ("id_nf", "ncm") -- Define "id_nf" e "ncm" como chave composta para identificar a nota fiscal e seus itens.
);

CREATE TABLE IF NOT EXISTS "destinatario" (
	 -- Registro de destinatários que recebem os lotes de embalagens ou lotes de produto que contém embalagens.
	"id_cnpj_destinatario" char(14) NOT NULL,  -- CNPJ do destinatário.
	"razao_social" varchar(100) NOT NULL, -- Razão social do destinatário.
	"logradouro" varchar(200) NOT NULL, -- Endereço do destinatário.
	"numero" varchar(10) NOT NULL,  -- Número do endereço.
	"complemento" varchar(50), -- Complemento do endereço.
	"bairro" varchar(50) NOT NULL,  -- Bairro do endereço.
	"cidade" varchar(50) NOT NULL, -- Cidade do destinatário.
	"estado" varchar(2) NOT NULL, -- Estado do destinatário.
	"cep" char(8) NOT NULL, -- CEP do destinatário.
	"email" varchar(254), -- E-mail de contato.
	"telefone" varchar(20), -- Telefone de contato.
	"descricao" varchar(255), -- Descrição adicional.
	PRIMARY KEY ("id_cnpj_destinatario") -- Define "id_cnpj_destinatario" como chave primária para identificar o destinatário.
);

CREATE TABLE IF NOT EXISTS "credito_reciclagem" (
	 -- Registro de créditos de reciclagem adquiridos pelas empresas.
	"id_credito" varchar(50) NOT NULL UNIQUE, -- Identificador único do crédito de reciclagem.
	"credito_lote" varchar(50) NOT NULL, -- Lote de embalagens relacionado ao crédito.
	"cooperativa" char(14) NOT NULL, -- CNPJ da cooperativa que emitiu o crédito.
	"data_aquisicao" date NOT NULL, -- Data de aquisição do crédito.
	"tipo_credito" varchar(50) CHECK(tipo_credito in ('plastico', 'papel', 'vidro', 'metal', 'aluminio')), -- Tipo de material reciclado.
	"quantidade_credito" numeric(10, 2) NOT NULL, -- Quantidade de material reciclado (em toneladas).
	"valor_unitario_cr" numeric(15, 2) NOT NULL, -- Valor unitário do crédito de reciclagem.
	"valor_total" numeric 
		GENERATED ALWAYS AS ("quantidade_credito" * "valor_unitario_cr") STORED, -- Valor total em reais do crédito de reciclagem.
	"descricao" varchar(255), -- Descrição adicional.
	PRIMARY KEY ("id_credito") -- Define ""id_credito"" como chave primária para identificar o crédito de reciclagem.
);

CREATE TABLE IF NOT EXISTS "cooperativa_de_reciclagem" (
	-- Informações sobre as cooperativas de reciclagem responsáveis pela emissão dos créditos.
	"id_cnpj_coop" char(14) NOT NULL, -- CNPJ da cooperativa.
	"razao_social" varchar(100) NOT NULL, -- Razão social da cooperativa.
	"logradouro" varchar(200) NOT NULL, -- Endereço da cooperativa.
	"numero" varchar(10) NOT NULL, -- Número do endereço.
	"complemento" varchar(50), -- Complemento do endereço.
	"bairro" varchar(50) NOT NULL, -- Bairro do endereço.
	"cidade" varchar(50) NOT NULL, -- Cidade da cooperativa.
	"estado" varchar(2) NOT NULL, -- Estado da cooperativa.
	"cep" char(8) NOT NULL, -- CEP da cooperativa.
	"email" varchar(254), -- E-mail de contato.
	"telefone" varchar(20), -- Telefone de contato.
	"descricao" varchar(255), -- Descrição adicional.
	PRIMARY KEY ("id_cnpj_coop") -- Chave primária para identificar a cooperativa.
);

-- Chaves estrangeiras

-- Relaciona o lote ao fabricante.
ALTER TABLE "lote_embalagem" ADD CONSTRAINT "lote_embalagem_fk1" FOREIGN KEY ("fabricante") REFERENCES "fabricante"("id_cnpj_fabricante");

-- Relaciona a nota fiscal ao emissor.
ALTER TABLE "nota_fiscal" ADD CONSTRAINT "nota_fiscal_fk2" FOREIGN KEY ("emissor") REFERENCES "fabricante"("id_cnpj_fabricante");

-- Relaciona a nota fiscal ao destinatário.
ALTER TABLE "nota_fiscal" ADD CONSTRAINT "nota_fiscal_fk3" FOREIGN KEY ("destinatario") REFERENCES "destinatario"("id_cnpj_destinatario");

-- Relaciona a nota fiscal ao lote de embalagens.
ALTER TABLE "nota_fiscal" ADD CONSTRAINT "nota_fiscal_fk4" FOREIGN KEY ("lote") REFERENCES "lote_embalagem"("codigo_lote");

-- Relaciona o crédito ao lote de embalagens.
ALTER TABLE "credito_reciclagem" ADD CONSTRAINT "credito_reciclagem_fk1" FOREIGN KEY ("credito_lote") REFERENCES "lote_embalagem"("codigo_lote");

-- Relaciona o crédito à cooperativa de reciclagem.
ALTER TABLE "credito_reciclagem" ADD CONSTRAINT "credito_reciclagem_fk2" FOREIGN KEY ("cooperativa") REFERENCES "cooperativa_de_reciclagem"("id_cnpj_coop");