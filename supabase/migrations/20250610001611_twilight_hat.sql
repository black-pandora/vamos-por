/*
  # Modelo Relacional - Salgados da Sara (REV 2)
  
  1. Novas Tabelas
    - `cidade` - Cidades atendidas
    - `endereco` - Endereços dos clientes
    - `categoria` - Categorias de produtos
    - `preco_delivery` - Preços de entrega
    - `delivery` - Informações de entrega
    - `pedido_produto` - Relacionamento pedido-produto
    - `admin` - Administradores do sistema
  
  2. Tabelas Modificadas
    - `cliente` (antiga usuarios) - Agora referencia endereco e cidade
    - `pedido` (antiga pedidos) - Estrutura simplificada
    - `produto` (antiga produtos) - Agora referencia categoria
  
  3. Segurança
    - Chaves estrangeiras para integridade referencial
    - Índices para performance
*/

-- Limpar tabelas existentes se necessário
DROP TABLE IF EXISTS historico_status_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS usuarios_admin CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS configuracoes_app CASCADE;

-- Criar novas tabelas seguindo o modelo relacional

-- Tabela cidade
CREATE TABLE IF NOT EXISTS cidade (
    sigla VARCHAR(5) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela endereco
CREATE TABLE IF NOT EXISTS endereco (
    id_endereco SERIAL PRIMARY KEY,
    rua VARCHAR(255) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    cep VARCHAR(10),
    complemento VARCHAR(255),
    bairro VARCHAR(100)
);

-- Tabela categoria
CREATE TABLE IF NOT EXISTS categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) NOT NULL UNIQUE,
    descricao_categoria TEXT
);

-- Tabela preco_delivery
CREATE TABLE IF NOT EXISTS preco_delivery (
    cod_preco SERIAL PRIMARY KEY,
    valor DECIMAL(10,2) NOT NULL,
    descricao VARCHAR(255)
);

-- Tabela cliente (antiga usuarios)
CREATE TABLE IF NOT EXISTS cliente (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    id_endereco INTEGER REFERENCES endereco(id_endereco),
    sigla_cidade VARCHAR(5) REFERENCES cidade(sigla),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela produto
CREATE TABLE IF NOT EXISTS produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    sabor VARCHAR(100),
    id_categoria INTEGER REFERENCES categoria(id_categoria),
    eh_porcionado BOOLEAN DEFAULT FALSE,
    eh_personalizado BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela pedido
CREATE TABLE IF NOT EXISTS pedido (
    id_pedido SERIAL PRIMARY KEY,
    numero_pedido VARCHAR(50) UNIQUE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    forma_pagamento VARCHAR(50) DEFAULT 'dinheiro',
    forma_entrega VARCHAR(50) DEFAULT 'retirada',
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_entrega TIMESTAMP,
    codigo_cliente INTEGER REFERENCES cliente(codigo),
    observacoes TEXT
);

-- Tabela pedido_produto (relacionamento N:N)
CREATE TABLE IF NOT EXISTS pedido_produto (
    id_pedido INTEGER REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    id_produto INTEGER REFERENCES produto(id_produto),
    quantidade INTEGER NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    tipo_quantidade VARCHAR(20) DEFAULT 'cento',
    quantidade_unidades INTEGER DEFAULT 1,
    PRIMARY KEY (id_pedido, id_produto, tipo_quantidade, quantidade_unidades)
);

-- Tabela delivery
CREATE TABLE IF NOT EXISTS delivery (
    id_delivery SERIAL PRIMARY KEY,
    hora_delivery TIME,
    endereco TEXT NOT NULL,
    id_pedido INTEGER UNIQUE REFERENCES pedido(id_pedido),
    sigla_cidade VARCHAR(5) REFERENCES cidade(sigla),
    id_preco INTEGER REFERENCES preco_delivery(cod_preco)
);

-- Tabela admin
CREATE TABLE IF NOT EXISTS admin (
    cod_admin SERIAL PRIMARY KEY,
    login VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    super_admin BOOLEAN DEFAULT FALSE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir dados iniciais

-- Cidades atendidas
INSERT INTO cidade (sigla, nome) VALUES
('QN', 'Quinze de Novembro'),
('SB', 'Selbach'),
('CO', 'Colorado'),
('AA', 'Alto Alegre'),
('FV', 'Fortaleza dos Valos'),
('TP', 'Tapera'),
('LTC', 'Lagoa dos Três Cantos'),
('SM', 'Saldanha Marinho'),
('EP', 'Espumoso'),
('CB', 'Campos Borges'),
('SBS', 'Santa Bárbara do Sul'),
('NMT', 'Não-Me-Toque'),
('BVC', 'Boa Vista do Cadeado'),
('BVI', 'Boa Vista do Incra'),
('CZ', 'Carazinho')
ON CONFLICT (sigla) DO NOTHING;

-- Categorias de produtos
INSERT INTO categoria (nome_categoria, descricao_categoria) VALUES
('Salgados Fritos', 'Salgados tradicionais fritos'),
('Sortidos', 'Mix de salgados variados'),
('Assados', 'Produtos assados no forno'),
('Especiais', 'Produtos especiais e tortas'),
('Opcionais', 'Bebidas e acompanhamentos')
ON CONFLICT (nome_categoria) DO NOTHING;

-- Preços de delivery
INSERT INTO preco_delivery (valor, descricao) VALUES
(10.00, 'Taxa padrão de entrega'),
(15.00, 'Taxa para cidades mais distantes'),
(0.00, 'Entrega gratuita para pedidos acima de R$ 100,00')
ON CONFLICT DO NOTHING;

-- Produtos padrão
INSERT INTO produto (nome, preco, sabor, id_categoria, eh_porcionado, eh_personalizado) VALUES
('Coxinha', 110.00, 'Frango', 1, false, false),
('Coxinha', 120.00, 'Frango com Catupiry', 1, false, false),
('Bolinha de Queijo', 100.00, 'Queijo', 1, false, false),
('Risole', 130.00, 'Camarão', 1, false, false),
('Pastel', 90.00, 'Carne', 1, false, false),
('Pastel', 85.00, 'Queijo', 1, false, false),
('Enroladinho de Salsicha', 95.00, 'Salsicha', 1, false, false),
('Sortido Simples', 95.00, 'Variado', 2, false, false),
('Sortido Especial', 110.00, 'Variado Premium', 2, false, false),
('Pão de Açúcar', 100.00, 'Doce', 3, false, false),
('Pão de Batata', 105.00, 'Batata', 3, false, false),
('Esfirra', 120.00, 'Carne', 3, false, false),
('Esfirra', 115.00, 'Queijo', 3, false, false),
('Torta Salgada', 25.00, 'Variado', 4, true, false),
('Quiche', 20.00, 'Variado', 4, true, false),
('Refrigerante Lata', 5.00, 'Variado', 5, true, false),
('Suco Natural', 8.00, 'Variado', 5, true, false)
ON CONFLICT DO NOTHING;

-- Administrador padrão
INSERT INTO admin (login, senha, super_admin) 
VALUES ('sara', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', true)
ON CONFLICT (login) DO NOTHING;
-- Senha padrão: password

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_cliente_telefone ON cliente(telefone);
CREATE INDEX IF NOT EXISTS idx_cliente_email ON cliente(email);
CREATE INDEX IF NOT EXISTS idx_pedido_status ON pedido(status);
CREATE INDEX IF NOT EXISTS idx_pedido_data ON pedido(data_pedido);
CREATE INDEX IF NOT EXISTS idx_pedido_cliente ON pedido(codigo_cliente);
CREATE INDEX IF NOT EXISTS idx_produto_categoria ON produto(id_categoria);
CREATE INDEX IF NOT EXISTS idx_delivery_pedido ON delivery(id_pedido);