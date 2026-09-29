--view pedidos detalhados
create or replace view VW_PEDIDOS_DETALHADOS as (
select p.id as pedido_id, 
c.nome as cliente,
p.data_pedido,
pr.nome as produto,
i.quantidade,
i.preco_unit,
(i.quantidade * i.preco_unit ) as sub_total
from pedidos p 
inner join clientes c  
on c.id = p.cliente_id
inner join pedido_itens i
on i.pedido_id = p.id
inner join produtos pr 
on pr.id = i.produto_id
order by p.id
)

select * from VW_PEDIDOS_DETALHADOS


--view para total por cliente

create or replace view VW_TOTAL_POR_CLIENTE as (
select c.nome as cliente,
	  SUM(pi.preco_unit * pi.quantidade) as total_preco
from pedidos p 
inner join clientes c
on p.cliente_id = c.id 
inner join pedido_itens pi
on pi.pedido_id = p.id
group by cliente
)

select * from VW_TOTAL_POR_CLIENTE;


--view para resumo de pedidos

create or replace view VW_PEDIDOS_RESUMO as (
select Count(p.*) as qtde_pedidos,
	   sum(preco_unit) as preco_total,
	   sum(t.quantidade) as qtde_produtos
from pedidos p
inner join pedido_itens t 
on t.pedido_id  = p.id 
inner join produtos pr 
on pr.id = t.produto_id
)

select * from VW_PEDIDOS_RESUMO;


--view para vendas por cidade

create or replace view VW_VENDAS_POR_CIDADE as (
select c.cidade,
       SUM(pi.quantidade) as total_produtos
from clientes c
inner join pedidos p 
on c.id = p.cliente_id
inner join pedido_itens pi 
on p.id = pi.pedido_id
group by c.cidade
order by total_produtos desc
)

select * from VW_VENDAS_POR_CIDADE;

--view para produtos mais vendidos

create or replace view VW_PRODUTOS_MAIS_VENDIDOS as (
select p.nome as nome_produto, 
		p.preco, 
		SUM(pit.preco_unit * pit.quantidade) as total_vendido,
		pit.quantidade as quantidade_produto
from produtos p
inner join pedido_itens pit
on pit.produto_id = p.id
group by nome_produto, quantidade_produto, p.preco
order by pit.quantidade desc,p.preco DESC, p.nome
)

select * from VW_PRODUTOS_MAIS_VENDIDOS;


--funçao para calcular o total do pedido

select fn_calcula_total_pedido(1);


create or replace function fn_calcula_total_pedido(p_pedido_id INT)
returns DECIMAL as $$
declare
	v_total DECIMAL := 0;
begin

	SELECT SUM(i.quantidade * i.preco_unit)
	INTO v_total
	FROM pedido_itens i
	WHERE i.pedido_id = p_pedido_id;

	RETURN coalesce(v_total,0);
	
end;

$$ language plpgsql;
