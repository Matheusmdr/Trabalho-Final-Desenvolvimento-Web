create database if not exists newgamesdb;
use newgamesdb;

-- SET FOREIGN_KEY_CHECKS=0;
-- SET GLOBAL FOREIGN_KEY_CHECKS=0;

-- Criação do banco ----------------------------------------------
-- tabelas ----------------------------------------------
create table if not exists supplier(
	id_supplier int not null auto_increment,
    supplier_name varchar(120) not null,
    primary_phone varchar(120) not null,
    secondary_phone varchar(120),
    primary_email varchar(120) not null,
    secondary_email varchar(120),
    website varchar(120),
    
    primary key(id_supplier)
);

create table if not exists category(
	id_category int auto_increment,
    category_name varchar(120) not null,
    category_description varchar(200),
    
    primary key(id_category)
);

create table if not exists game(
	id_game int auto_increment,
    game_name varchar(120) not null unique,
    price decimal(6,2) not null,
    img varchar(120) not null,
    supplier int not null,
    
    primary key(id_game),
    foreign key(supplier) references supplier(id_supplier)
);

create table if not exists connection_game_category(
	id_game int not null,
    id_category int not null,
    
    foreign key(id_game) references game(id_game),
    foreign key(id_category) references category(id_category)
);

create table if not exists library(
	id_lib int not null auto_increment,
    
    primary key(id_lib)
);

create table if not exists connection_lib_and_game(
	id_game int not null,
    id_lib int not null,
    
    foreign key(id_game) references game(id_game),
    foreign key(id_lib) references library(id_lib)
);

create table if not exists wishlist(
	id_wishlist int not null auto_increment,
    
    primary key(id_wishlist)
);

create table if not exists connection_wishlist_and_game(
	id_game int not null,
    id_wishlist int not null,
    
    foreign key(id_game) references game(id_game),
    foreign key(id_wishlist) references wishlist(id_wishlist)
);

create table if not exists adress(
	id_adress int not null auto_increment,
    country varchar(80) not null,
    state varchar(80) not null,
    city varchar(80) not null,
    neighborhood varchar(80) not null,
    zip_code char(8) not null,
    street varchar(80) not null,
    house_number int,
    
    primary key(id_adress)
);

create table if not exists clients (
    id_client int not null auto_increment,
    client_name varchar(200) not null,
    email varchar(50) not null unique,
    client_password varchar(80) not null,
	adress int not null,
    id_lib int not null,
    id_wishlist int not null,
    
    primary key (id_client),
    foreign key(adress) references adress(id_adress),
    foreign key(id_lib) references library(id_lib),
    foreign key(id_wishlist) references wishlist(id_wishlist)
);

create table if not exists purchase(
	id_purchase int not null auto_increment,
    date_time datetime not null,
    cost decimal(10,2) not null,
    discount decimal(6,2),
    payment_method varchar(120) not null,
    payment_installments tinyint not null,
    id_client int not null,
    
    primary key(id_purchase),
    foreign key(id_client) references clients(id_client)
);

create table if not exists connection_purchase_game(
	id_game int not null,
    id_purchase int not null,
    
    
    foreign key(id_game) references game(id_game),
    foreign key(id_purchase) references purchase(id_purchase)
);

create table if not exists employee(
	id_employee int not null auto_increment,
    employee_name varchar(200) not null,
    email varchar(200) not null unique,
    employee_password varchar(200) not null,
    adress int not null,
    
    primary key(id_employee),
    foreign key(adress) references adress(id_adress)
);

create table if not exists budget(
	input decimal(8,2) not null,
    output decimal(8,2) not null,
    transation_description varchar(200) not null
);

-- Triggers ---------------------------------------------------------
/*Inicializa uma biblioteca de jogos para cada usuário criado. Caso apresente algum erro, a mesma já elimina a biblioteca criada*/
delimiter $$
create trigger user_before_insert before insert on clients
for each row
begin
	begin
		declare id_library int;
    
		declare exit handler for sqlexception
		begin
			delete from library where id_lib = id_library;
		end;
    
		insert into library(id_lib) values(null);
		select last_insert_id() into id_library;
    
		set new.id_lib = id_library;
	end;
    
	begin
		declare id_wishl int;
    
		declare exit handler for sqlexception
		begin
			delete from wishlist where id_wishlist = id_wishl;
		end;
    
		insert into wishlist(id_wishlist) values(null);
		select last_insert_id() into id_wishl;
    
		set new.id_wishlist = id_wishl;
    end;
    
    if new.client_name = null then
        signal sqlstate '45000' set message_text = 'no username', mysql_errno = 1364;
    end if;

    if new.email = null then
        signal sqlstate '45000' set message_text = 'no email', mysql_errno = 1364;
    end if;

    if new.client_password = null then
        signal sqlstate '45000' set message_text = 'no password', mysql_errno = 1364;
    end if;    
    
    if new.adress = null then
        signal sqlstate '45000' set message_text = 'no country', mysql_errno = 1364;
    end if;      
       
end$$
delimiter ;

-- ----------------------------------------------------------------------------

/*função para deletar a lib do usuário, para ela n existir qnd ele for deletado*/
delimiter $$
create trigger user_before_delete before delete on clients
for each row
begin
	
end$$
delimiter ;
-- ----------------------------------------------------------------------------
/*verificar se o usuário já tem o game. Não inserir o game caso o usuário já tenha. (vale o msm p wishlist)*/
delimiter $$
create trigger lib_before_insert_game before insert on connection_lib_and_game
for each row
begin

end$$
delimiter ;
-- registra orçamento------------------------------------------------------------------
delimiter $$
create trigger after_purchase_insert_budget after insert on purchase
for each row
begin
	insert into budget(input,output,transation_description)
		(select sum(cost),0.00, concat("purchase ", new.id_purchase) from purchase);
end$$
delimiter ;

-- inserção do banco ----------------------------------------------
-- inserindo funcionários --------------------------------------
-- criando endereço 
insert into adress(country,state,city,neighborhood,zip_code,street,house_number) values("Brazil","São Paulo","São Paulo", "Bairro 0", "11929391","Rua teste",190);

select * from adress;

-- criando funcionário
insert into employee(employee_name,email,employee_password,adress) values("Rodrigo Araújo Neto","rodrigo_araujo@gmail.com",MD5("senha123"),1);

select * from employee;
-- inserindo fornecedores
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("SEGA","+551139068215","+551137062215","sega1@gmail.com", "sega2@gmail.com","https://www.sega.com");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("CAPCOM","+551139068635","+551137002150","capcom1@gmail.com", "capcom2@gmail.com","https://www.capcom.com/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("CD PROJEKT RED","+551139068005","+55113700205","cdprojektred1@gmail.com", "cdprojektred2@gmail.com","https://en.cdprojektred.com/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("BANDAI NAMCO","+551139000215","+551137062255","bandai1@gmail.com", "bandai2@gmail.com","https://www.bandainamcoent.com/pt-br/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("KOEI TECMO","+551139068215","+551137062215","koeitecmo1@gmail.com", "koeitecmo2@gmail.com","https://www.koeitecmo.co.jp/e/company/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("Rockstar Games","+551130068215","+552137062215","rockstar1@gmail.com", "rockstar2@gmail.com","https://www.rockstargames.com/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("方块游戏 (CubeGame)","+5551130068215","+5552137062215","cubegame1@gmail.com", "cubegame2@gmail.com","https://www.cubejoy.com/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("SQUARE ENIX","+5551130068215","+5552137062215","square_enix1@gmail.com", "square_enix2@gmail.com","https://square-enix-games.com/pt_BR/home");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("Team Cherry","+8551130068215","+5952137062215","teamcherry1@gmail.com", "teamcherry2@gmail.com","https://www.teamcherry.com.au/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("Motion Twin","+9551130068215","+7952137062215","motiontwin1@gmail.com", "motiontwin2@gmail.com","http://motion-twin.com/en/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("KONAMI","+2551130068215","+3952137062215","konami1@gmail.com", "konami2@gmail.com","https://www.konami.com/en/");
insert into supplier(supplier_name,primary_phone,secondary_phone,primary_email, secondary_email,website) values("PSYONIX","+08551130068215","+1952137062215","psyonix1@gmail.com", "psyonix2@gmail.com","https://www.psyonix.com/");

select * from supplier;
-- inserindo categoria dos jogos
insert into category(category_name, category_description) values("RPG","Game genre in which players advance through a story quest, and often many side quests, for which their character or party of characters gain experience that improves various attributes and abilities.");
insert into category(category_name, category_description) values("Survival horror","No description.");
insert into category(category_name, category_description) values("Action","No description.");
insert into category(category_name, category_description) values("Platform","No description.");
insert into category(category_name, category_description) values("Multiplayer","No description.");

-- delete from category where id_category = 5;
select * from category;
-- inserindo jogos
insert into game(game_name, price, img, supplier) values("Persona 5 Strikers",59.99,"Persona5S.jpg",1);
insert into game(game_name, price, img, supplier) values("Resident Evil Village",79.99,"RESIDENT-EVIL-8-1.jpg",2);
insert into game(game_name, price, img, supplier) values("Cyberpunk 2077",47.99,"cyberpunk.jpg",3);
insert into game(game_name, price, img, supplier) values("Dark Souls 3",59.99,"darksouls3.jpg",4);
insert into game(game_name, price, img, supplier) values("The Witcher 3: Wild Hunt",7.99,"the-witcher-3-wild-hunt.jpg",3);
insert into game(game_name, price, img, supplier) values("Devil May Cry 5",24.99,"devil-may-cry-5.jpg",2);
insert into game(game_name, price, img, supplier) values("Nioh 2",39.99,"nioh2.jpg",5);
insert into game(game_name, price, img, supplier) values("Red Dead Redemption 2",14.99,"ReadDeadRedemption 2.jpg",6);
insert into game(game_name, price, img, supplier) values("Sekiro: Shadows Die Twice",59.99,"Sekiro-Shadows-Die-Twice.jpg",7);
insert into game(game_name, price, img, supplier) values("KINGDOM HEARTS III + Re Mind",59.99,"EGS_KINGDOMHEARTSIIIReMindDLC.jpg",8);
insert into game(game_name, price, img, supplier) values("Hollow Knight",14.99,"hollowknight.jpg",9);
insert into game(game_name, price, img, supplier) values("Sonic Mania",9.99,"SonicMania.jpg",1);
insert into game(game_name, price, img, supplier) values("Dead Cells",24.99,"DeadCells.jpg",10);
insert into game(game_name, price, img, supplier) values("Super Bomberman R Online",9.99,"Super-Bomberman-R.jpg",11);
insert into game(game_name, price, img, supplier) values("Rocket League",9.99,"rocketleague.jpg",12);

select * from game;
-- inserindo conexão entre jogo e categoria
insert into connection_game_category(id_game,id_category) values(1,1);
insert into connection_game_category(id_game,id_category) values(2,2);
insert into connection_game_category(id_game,id_category) values(3,1);
insert into connection_game_category(id_game,id_category) values(4,1);
insert into connection_game_category(id_game,id_category) values(5,1);
insert into connection_game_category(id_game,id_category) values(6,3);
insert into connection_game_category(id_game,id_category) values(7,3);
insert into connection_game_category(id_game,id_category) values(8,3);
insert into connection_game_category(id_game,id_category) values(9,3);
insert into connection_game_category(id_game,id_category) values(10,1);
insert into connection_game_category(id_game,id_category) values(11,4);
insert into connection_game_category(id_game,id_category) values(12,4);
insert into connection_game_category(id_game,id_category) values(13,4);
insert into connection_game_category(id_game,id_category) values(14,5);
insert into connection_game_category(id_game,id_category) values(15,5);

-- delete from connection_game_category where id_game = 10 AND id_category = 4;

-- drop table connection_game_category;
select * from connection_game_category;
-- retorna todas as categorias daquele game
select * from connection_game_category where id_game = 1;

-- retorna o nome da categoria do jogo 
select category_name from category where id_category = (
	select id_category from connection_game_category where id_game = 1
);
-- retorna nome do jogo
select game_name from game where id_game = 2;

-- inserindo cliente ---------------------------------------------------
-- criando endereço ---------
insert into adress(country,state,city,neighborhood,zip_code,street,house_number) values("Brazil","São Paulo","Presidente Prudente", "Bairro 1", "19029396","Rua teste",170);
insert into adress(country,state,city,neighborhood,zip_code,street,house_number) values("Brazil","São Paulo","Álvares Machado", "Bairro 2", "18019390","Rua teste 2",90);
insert into adress(country,state,city,neighborhood,zip_code,street,house_number) values("Brazil","São Paulo","Presidente Epitácio", "Bairro 3", "19021391","Rua teste3",235);
select * from adress;

insert into clients(client_name,email,client_password,adress) values("João Antônio Soares","joao_antonio@gmail.com",MD5("senha123"),2);
insert into clients(client_name,email,client_password,adress) values("Maria Joana Costa","maria_joana@gmail.com",MD5("senha123"),3);
insert into clients(client_name,email,client_password,adress) values("Augusto Pereira Silva","augusto_pereira@gmail.com",MD5("senha123"),4);
select * from clients;

select * from library; -- lib e wishlist são criadas automaticamente ao inserir cliente

-- busca os dados de endereço do cliente através do nome
select country,state,city,neighborhood,zip_code,street,house_number from adress where id_adress = (
	select adress from clients where client_name = "João Antônio Soares"
);

-- Compra ------------------------------------------------------------------------------------------
-- Setando Timezone correta (Brasil/São Paulo)
SET @@global.time_zone = '+03:00';
SET GLOBAL time_zone = '+3:00';

-- registrando compra
insert into purchase(date_time,cost,discount,payment_method,payment_installments,id_client) values('2021-09-01 23:59:59',9.99,0.99,"credit card",1,1);
insert into purchase(date_time,cost,discount,payment_method,payment_installments,id_client) values('2021-09-02 20:50:59',14.99,0.99,"credit card",1,1);
insert into purchase(date_time,cost,discount,payment_method,payment_installments,id_client) values('2021-10-05 14:50:59',24.98,0.00,"credit card",1,2);
insert into purchase(date_time,cost,discount,payment_method,payment_installments,id_client) values('2021-10-05 21:10:08',39.99,0.00,"credit card",1,3);
select * from purchase;
select * from budget;
select * from clients;
select * from connection_purchase_game;

-- registrando o que foi comprado e em qual registro de compra
insert into connection_purchase_game(id_game,id_purchase) values(12,1);
insert into connection_purchase_game(id_game,id_purchase) values(8,1);
insert into connection_purchase_game(id_game,id_purchase) values(11,2);
insert into connection_purchase_game(id_game,id_purchase) values(11,3);
insert into connection_purchase_game(id_game,id_purchase) values(12,3);
insert into connection_purchase_game(id_game,id_purchase) values(7,4);
select * from connection_purchase_game;

select * from clients;
select * from library;
select * from connection_lib_and_game;
select * from game;

-- inserindo games comprados nas libs
insert into connection_lib_and_game(id_game,id_lib) values(12,1);
insert into connection_lib_and_game(id_game,id_lib) values(8,1);
insert into connection_lib_and_game(id_game,id_lib) values(11,1);
insert into connection_lib_and_game(id_game,id_lib) values(11,2);
insert into connection_lib_and_game(id_game,id_lib) values(12,2);
insert into connection_lib_and_game(id_game,id_lib) values(7,3);

-- seleciona todos os games da lib do cliente, através do id_client
select * from connection_lib_and_game where id_lib = (
	select id_lib from clients where id_client = 3
);

-- seleciona os ids das compras realizadas por esse cliente
select id_purchase from purchase where id_client = (
	select id_client from clients where client_name = "João Antônio Soares"
);

-- seleciona os nome do jogo comprado naquela compra, através do id de compra
select game_name from game where id_game = (
	select id_game from connection_purchase_game where id_purchase = (
	2
    ) 
);

select id_game from connection_purchase_game where id_purchase = 1;        

select * from connection_purchase_game;
select * from purchase;
select * from clients;

-- nome de quem realizou a compra e quando
select purchase.id_purchase,  clients.client_name, purchase.date_time 
	from purchase inner join clients on purchase.id_client = clients.id_client;
    
-- id da compra e nome do jogo
select connection_purchase_game.id_purchase, game.game_name
	from connection_purchase_game inner join game on connection_purchase_game.id_game = game.id_game;


-- código da compra, nome de quem realizou a compra, quando, o que foi comprado, id_game e para qual lib
select purchase.id_purchase, clients.client_name, purchase.date_time, game.game_name, game.id_game, clients.id_lib
	from game 
		inner join connection_purchase_game on game.id_game = connection_purchase_game.id_game
		inner join purchase on connection_purchase_game.id_purchase = purchase.id_purchase
        inner join clients on purchase.id_client = clients.id_client;

-- games na wishlist --------------------------------
select * from clients;
select * from wishlist;
select * from game;

-- inserindo games na wishlist
insert into connection_wishlist_and_game(id_game,id_wishlist) values(3,1);
insert into connection_wishlist_and_game(id_game,id_wishlist) values(1,1);
insert into connection_wishlist_and_game(id_game,id_wishlist) values(2,2);
insert into connection_wishlist_and_game(id_game,id_wishlist) values(9,3);
insert into connection_wishlist_and_game(id_game,id_wishlist) values(3,2);
insert into connection_wishlist_and_game(id_game,id_wishlist) values(10,1);

select * from connection_wishlist_and_game;

-- seleciona todos os games da wishlist do cliente, através do id_client
select * from connection_wishlist_and_game where id_wishlist = (
	select id_wishlist from clients where id_client = 1
);

-- drop database newgamesdb;