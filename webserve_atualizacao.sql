create database webserver;
use webserver;

create table genero(
	id_genero int primary key auto_increment,
    tipo varchar(50)
);

create table ator(
	id_ator int primary key auto_increment,
    nome varchar(15),
    sobrenome varchar(20),
    genero enum("Feminino","Masculino"),
    nacionalidade varchar(50)
);

create table diretor(
	id_diretor int primary key auto_increment,
    nome varchar(15),
    sobrenome varchar(20),
    genero enum("Feminino","Masculino"),
    nacionalidade varchar(50)
);

create table linguagem(
	id_linguagem int primary key auto_increment,
    idioma varchar(20)
);

create table pais(
	id_pais int primary key auto_increment,
    nome varchar(50),
    continente varchar(50)
);

create table produtora(
	id_produtora int primary key auto_increment,
    nome varchar(70),
	id_pais int,
	foreign key (id_pais) references pais(id_pais)
);

create table filme(
	id_filme int primary key auto_increment,
    titulo varchar(100),
    orcamento float,
    id_diretor int,
    tempo_de_duracao time,
    ano year,
    id_linguagem int,
    id_genero int,
    id_ator int,
    id_produtora int,
    poster blob,
    foreign key (id_diretor) references diretor(id_diretor),
    foreign key (id_linguagem) references linguagem(id_linguagem),
    foreign key (id_genero) references genero(id_genero),
    foreign key (id_ator) references ator(id_ator),
    foreign key (id_produtora) references produtora(id_produtora)
);

create table filme_linguagem(
	id_filme_linguagem int primary key auto_increment,
    id_filme int,
    id_linguagem int,
    foreign key (id_filme) references filme(id_filme),
    foreign key (id_linguagem) references linguagem(id_linguagem)
);

create table filme_ator(
	id_filme_ator int primary key auto_increment,
    id_filme int,
    id_ator int,
    foreign key (id_filme) references filme(id_filme),
    foreign key (id_ator) references ator(id_ator)
);

create table filme_genero(
	id_filme_genero int primary key auto_increment,
    id_filme int,
    id_genero int,
    foreign key (id_filme) references filme(id_filme),
    foreign key (id_genero) references genero(id_genero)
);

create table filme_produtora(
	id_filme_produtora int primary key auto_increment,
    id_filme int,
    id_produtora int,
    foreign key (id_filme) references filme(id_filme),
    foreign key (id_produtora) references produtora(id_produtora)
);

INSERT INTO genero (tipo) VALUES
('Ação'), ('Aventura'), ('Comédia'), ('Drama'), ('Ficção Científica'),
('Terror'), ('Romance'), ('Suspense'), ('Animação'), ('Fantasia');

INSERT INTO pais (nome, continente) VALUES
('Estados Unidos', 'América do Norte'), ('Reino Unido', 'Europa'),
('Canadá', 'América do Norte'), ('França', 'Europa'), ('Japão', 'Ásia'),
('Brasil', 'América do Sul'), ('Alemanha', 'Europa');

INSERT INTO linguagem (idioma) VALUES
('Inglês'), ('Espanhol'), ('Português'), ('Francês'), ('Japonês'), ('Alemão');

INSERT INTO produtora (nome, id_pais) VALUES
('Warner Bros. Pictures', 1),('20th Century Fox', 1),('Universal Pictures', 1),('Paramount Pictures', 1),
('Walt Disney Pictures', 1),('Sony Pictures', 7),('Netflix', 2),('Studio Ghibli', 5),('Globo Filmes', 6),('BBC Films', 2);

INSERT INTO ator (nome, sobrenome, genero, nacionalidade) VALUES
('Leonardo', 'DiCaprio', 'Masculino', 'Estados Unidos'),
('Tom', 'Hanks', 'Masculino', 'Estados Unidos'),
('Meryl', 'Streep', 'Feminino', 'Estados Unidos'),
('Scarlett', 'Johansson', 'Feminino', 'Estados Unidos'),
('Brad', 'Pitt', 'Masculino', 'Estados Unidos'),
('Tais', 'Araujo', 'Feminino', 'Brasil'),
('Daniel', 'Day-Lewis', 'Masculino', 'Reino Unido'),
('Margot', 'Robbie', 'Feminino', 'Austrália'),
('Ryan', 'Gosling', 'Masculino', 'Canadá'),
('Gal', 'Gadot', 'Feminino', 'Israel'),
('Keanu', 'Reeves', 'Masculino', 'Canadá'),
('Sandra', 'Bullock', 'Feminino', 'Estados Unidos');

INSERT INTO diretor (nome, sobrenome, genero, nacionalidade) VALUES
('Christopher', 'Nolan', 'Masculino', 'Reino Unido'),
('Greta', 'Gerwig', 'Feminino', 'Estados Unidos'),
('Steven', 'Spielberg', 'Masculino', 'Estados Unidos'),
('Quentin', 'Tarantino', 'Masculino', 'Estados Unidos'),
('Patty', 'Jenkins', 'Feminino', 'Estados Unidos'),
('Fernando', 'Meirelles', 'Masculino', 'Brasil'),
('Denis', 'Villeneuve', 'Masculino', 'Canadá'),
('Bong', 'Joon-ho', 'Masculino', 'Coreia do Sul');

INSERT INTO filme (titulo, orcamento, id_diretor, tempo_de_duracao, ano, id_linguagem, id_genero, id_ator, id_produtora, poster) VALUES
('A Origem', 160000000.00, 1, '02:28:00', 2010, 1, 5, 1, 1, NULL),               
('Barbie', 145000000.00, 2, '01:54:00', 2023, 1, 3, 8, 2, NULL),                 
('Jurassic Park', 200000000.00, 3, '02:07:00', 1993, 1, 2, 2, 3, NULL),         
('Pulp Fiction', 63000000.00, 4, '02:34:00', 1994, 1, 8, 5, 4, NULL),            
('Mulher-Maravilha', 180000000.00, 5, '02:21:00', 2017, 1, 1, 10, 5, NULL),      
('Cidade de Deus', 8000000.00, 6, '02:10:00', 2002, 3, 4, 6, 9, NULL),           
('Duna', 165000000.00, 7, '02:32:00', 2021, 1, 5, 1, 6, NULL),                   
('Parasita', 11000000.00, 8, '02:12:00', 2019, 5, 4, 7, 8, NULL),                
('O Resgate do Soldado Ryan', 250000000.00, 3, '02:50:00', 1998, 1, 4, 2, 3, NULL), 
('Interestelar', 185000000.00, 1, '02:49:00', 2014, 1, 5, 1, 1, NULL),           
('Django Livre', 50000000.00, 4, '02:45:00', 2012, 1, 1, 5, 2, NULL),           
('Adoráveis Mulheres', 100000000.00, 2, '02:15:00', 2019, 1, 4, 3, 7, NULL),     
('A Chegada', 75000000.00, 7, '01:58:00', 2016, 1, 5, 12, 3, NULL),              
('O Hospedeiro', 40000000.00, 8, '02:09:00', 2006, 5, 6, 11, 8, NULL),           
('Prenda-me Se For Capaz', 175000000.00, 3, '01:56:00', 2002, 1, 8, 1, 4, NULL), 
('360', 15000000.00, 6, '02:04:00', 2012, 1, 4, 6, 9, NULL),                  
('Oppenheimer', 225000000.00, 1, '03:00:00', 2023, 1, 4, 1, 10, NULL),       
('Bastardos Inglórios', 60000000.00, 4, '02:06:00', 2009, 1, 1, 5, 2, NULL),
('Mulher-Maravilha 1984', 120000000.00, 5, '02:31:00', 2020, 1, 1, 10, 5, NULL), 
('Blade Runner 2049', 90000000.00, 7, '02:04:00', 2017, 1, 5, 9, 6, NULL); 

INSERT INTO filme_ator (id_filme, id_ator) VALUES
(1, 1), (1, 5), (2, 8), (2, 9), (3, 2), (4, 5), (4, 11),
(5, 10), (6, 6), (7, 1), (7, 10), (8, 7), (9, 2), (9, 7),
(10, 1), (11, 5), (11, 1), (12, 3), (12, 8), (13, 12),
(14, 11), (15, 1), (15, 2), (16, 6), (17, 1), (17, 7),
(18, 5), (18, 3), (19, 10), (20, 9), (20, 4);

INSERT INTO filme_genero (id_filme, id_genero) VALUES
(1, 1), (1, 5), (2, 3), (2, 4), (3, 2), (3, 5), (4, 8), (4, 4),
(5, 1), (5, 2), (6, 4), (6, 8), (7, 5), (7, 2), (8, 4), (8, 8),
(9, 4), (9, 1), (10, 5), (10, 4), (11, 1), (11, 4), (12, 4), (12, 7),
(13, 5), (13, 4), (14, 6), (14, 5), (15, 8), (15, 4), (16, 4), (16, 8),
(17, 4), (17, 8), (18, 1), (18, 8), (19, 1), (19, 2), (20, 5), (20, 4);

INSERT INTO filme_linguagem (id_filme, id_linguagem) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 3), (7, 1), (7, 4), (8, 5),
(9, 1), (10, 1), (11, 1), (12, 1), (13, 1), (14, 5), (15, 1), (15, 4),
(16, 1), (16, 3), (17, 1), (18, 1), (18, 6), (19, 1), (20, 1);

INSERT INTO filme_produtora (id_filme, id_produtora) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 9), (7, 6), (8, 8), (9, 3),
(10, 1), (11, 2), (12, 7), (13, 3), (14, 8), (15, 4), (16, 9), (17, 10),
(18, 2), (19, 5), (20, 6);


alter table filme
add column sinopse text,
add column diretor varchar(100),
add column genero varchar(50),
add column produtora varchar(100),
add column atores varchar(255);



