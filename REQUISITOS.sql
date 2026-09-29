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