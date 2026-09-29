# Desafio de Engenharia de Dados

## Executar o banco com Docker

Com o Docker Desktop iniciado (containers Linux), execute na pasta do projeto:

```powershell
docker compose up -d --wait
```

O Compose utiliza a imagem oficial `postgres:17`, compatível com o `pg_dump` 17.6
que gerou `vendasx.backup`. Na primeira inicialização, o script
`docker/init/01-restore.sh` restaura o backup automaticamente com `pg_restore`.
O backup contém a estrutura das quatro tabelas, sem registros. Execute os
`INSERTs` da seção **Importação e Inserts** abaixo para popular os dados de exemplo.

Para conectar pelo DBeaver, pgAdmin ou outro cliente:

| Campo | Valor padrão |
| --- | --- |
| Host | `localhost` |
| Porta | `5432` |
| Banco | `vendasx` |
| Usuário | `postgres` |
| Senha | `postgres` |

A porta fica acessível somente na máquina local. Para alterar a senha ou a porta,
copie `.env.example` para `.env` e ajuste os valores antes da primeira execução.
Se a porta 5432 já estiver ocupada, configure `POSTGRES_PORT=5433` no `.env`.
Alterar a variável de senha após a criação do volume não altera a senha no banco.

Para abrir o terminal SQL:

```powershell
docker compose exec postgres psql -U postgres -d vendasx
```

Dentro do `psql`, liste as tabelas com `\dt`, execute consultas como
`SELECT * FROM clientes;` e saia com `\q`. Também é possível consultar diretamente:

```powershell
docker compose exec postgres psql -U postgres -d vendasx -c "SELECT * FROM clientes;"
```

Para acompanhar a restauração ou verificar o estado do serviço:

```powershell
docker compose logs postgres
docker compose ps
```

Para parar o ambiente preservando os dados no volume:

```powershell
docker compose down
```

A restauração automática ocorre somente quando o volume está vazio, conforme a
[documentação da imagem oficial](https://hub.docker.com/_/postgres).
Para começar novamente a partir do backup, os comandos abaixo **apagam todos os
dados locais do banco**, incluindo alterações feitas após a importação:

```powershell
docker compose down -v
docker compose up -d --wait
```

Se a restauração falhar, verifique os logs e corrija a causa antes de recriar o
volume com os comandos acima; um volume já inicializado não repete o script.

O objetivo é trabalhar conceitos de **consultas relacionais**, **agregações**, **funções PL/pgSQL** e **integração SQL → JSON**, utilizando o **PostgreSQL**.

---

## Cenário

Você está trabalhando em uma empresa que precisa analisar dados de **vendas e clientes**.  
Foi fornecido um banco de dados já estruturado com as tabelas:

- `clientes`
- `produtos`
- `pedidos`
- `pedido_itens`

Sua missão é **importar o banco de dados** disponibilizado e criar as *views* e *funções* solicitadas a seguir.

---

## Importação e Inserts

Após importar o banco, execute os comandos abaixo para popular as tabelas iniciais:

```sql
INSERT INTO clientes (nome, cidade) VALUES
('Ana Souza', 'Curitiba'),
('Bruno Lima', 'Florianópolis'),
('Carla Mendes', 'Porto Alegre');

INSERT INTO produtos (nome, preco) VALUES
('Notebook Lenovo', 4200.00),
('Mouse Logitech', 120.00),
('Monitor LG 24"', 950.00),
('Teclado Mecânico Redragon', 380.00);

INSERT INTO pedidos (cliente_id, data_pedido, valor_total)
VALUES
(1, '2025-11-10', 0), -- pedido da Ana
(2, '2025-11-11', 0); -- pedido do Bruno

-- Pedido 1 (Ana Souza)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unit) VALUES
(1, 1, 1, 4200.00), -- Notebook Lenovo
(1, 2, 1, 120.00);  -- Mouse Logitech

-- Pedido 2 (Bruno Lima)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unit) VALUES
(2, 3, 2, 950.00),  -- 2 Monitores LG
(2, 4, 1, 380.00);  -- Teclado Mecânico
```

## O que você deve fazer?

| Tipo   | Nome                        | Demonstra                  | Conceitos            |
| ------ | --------------------------- | -------------------------- | -------------------- |
| View   | `vw_pedidos_detalhados`     | JOIN + cálculo de subtotal | relacionamentos      |
| View   | `vw_total_por_cliente`      | GROUP BY + SUM             | agregação            |
| View   | `vw_pedidos_resumo`         | COUNT + SUM                | agrupamento          |
| View   | `vw_vendas_por_cidade`      | GROUP BY + ORDER BY        | análise por região   |
| View   | `vw_produtos_mais_vendidos` | SUM + ORDER BY DESC        | ranking              |
| Função | `fn_calcula_total_pedido`   | SELECT INTO + COALESCE     | função escalar       |
| Função | `fn_clientes_vip`           | HAVING + parâmetros        | filtro dinâmico      |
| Função | `fn_produtos_mais_vendidos` | retorno TABLE              | agregação            |
| Função | `fn_vendas_por_cidade`      | retorno TABLE + join       | agrupamento múltiplo |
| Função | `fn_pedido_json`            | JSON_BUILD_OBJECT          | integração API/SQL   |

