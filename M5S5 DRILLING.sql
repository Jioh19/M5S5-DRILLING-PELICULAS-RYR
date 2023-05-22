-- 1. Crear base de datos llamada: películas.

CREATE DATABASE peliculas;
\c peliculas;

-- 2. Revisar los archivos peliculas.csv y reparto.csv, para crear las tablas correspondientes,
-- determinando la relación entre ambas. Los nombres de los atributos en la tabla películas
-- serán: id, pelicula, estreno, director. Y los nombres de los atributos en la tabla reparto serán:
-- id_pelicula, actor.

CREATE TABLE peliculas (
    id int PRIMARY KEY, 
    pelicula varchar(120), 
    estreno int, 
    director varchar(120)
);

CREATE TABLE reparto (
    id_pelicula int,
    actor varchar(120), 
    CONSTRAINT fk_peliculas
        FOREIGN KEY(id_pelicula)
            REFERENCES peliculas(id)
);
-- 3. Cargar ambos archivos a su tabla correspondiente.
-- Esto lo puedes realizar utilizando la sentencia:
-- \COPY “nombre_tabla” FROM ‘C:\...\nombre_archivo.csv’ WITH CSV;
\COPY "peliculas" FROM 'C:\Users\Jioh\Downloads\Bootcamp Javascript\M5\ApoyoCSV\peliculas.csv' WITH CSV;
\COPY "reparto" FROM 'C:\Users\Jioh\Downloads\Bootcamp Javascript\M5\ApoyoCSV\reparto.csv' WITH CSV;

-- 7. Listar todos los actores que aparecen en la película "Titanic", indicando el título de la película,
-- año de estreno, director y todo el reparto.
SELECT p.pelicula, p.estreno, p.director, r.actor 
    FROM peliculas AS p, reparto AS r 
        WHERE pelicula = 'Titanic' 
            AND p.id = r.id_pelicula;

-- 8. Listar los 10 directores más populares, indicando su nombre y cuántas películas aparecen
-- en el top 100.
SELECT director, count(pelicula) 
    FROM peliculas
        GROUP BY director
            ORDER BY count DESC
                LIMIT 10;

-- 9. Indicar cuántos actores distintos hay.
SELECT DISTINCT actor 
    FROM reparto;

-- 10. Indicar las películas estrenadas entre los años 1990 y 1999 (ambos incluidos), ordenadas
-- por título de manera ascendente.
SELECT pelicula, estreno 
    FROM peliculas
        WHERE estreno <= 1999 AND estreno >= 1990
            ORDER BY estreno ASC;

-- 11. Listar los actores de la película más nueva.
SELECT r.actor, p.estreno, p.pelicula
    FROM reparto AS r, peliculas AS p
        WHERE p.estreno = (
            SELECT MAX(estreno) FROM peliculas) AND r.id_pelicula = p.id
            ORDER BY p.pelicula ASC;

-- 12. Inserte los datos de una nueva película solo en memoria, y otra película en el disco duro.
BEGIN TRANSACTION;
INSERT INTO peliculas
VALUES  
    (101, 'The Hot Chick', 2002, 'Tom Brady');
SAVEPOINT Thecat;
INSERT INTO peliculas
VALUES  
    (102, 'The Cat Returns', 2002, 'Hiroyuki Morita');
ROLLBACK TO Thecat;
COMMIT;

-- 13. Actualice 5 directores utilizando ROLLBACK.
BEGIN TRANSACTION;
UPDATE peliculas
    SET director = 'Juan Oh'
        WHERE id < 6;
ROLLBACK;

-- 14. Inserte 3 actores a la película “Rambo” utilizando SAVEPOINT
BEGIN TRANSACTION;
SAVEPOINT NoJuanOh;
INSERT INTO reparto
VALUES
    ((SELECT id FROM peliculas WHERE pelicula = 'Rambo'), 'Juan Oh1');
    ((SELECT id FROM peliculas WHERE pelicula = 'Rambo'), 'Juan Oh2');
    ((SELECT id FROM peliculas WHERE pelicula = 'Rambo'), 'Juan Oh3');
ROLLBACK TO NoJuanOh;

-- 15. Elimina las películas estrenadas el año 2008 solo en memoria.
BEGIN TRANSACTION;
ALTER TABLE reparto DROP CONSTRAINT fk_peliculas;
ALTER TABLE reparto ADD CONSTRAINT fk_peliculas 
    FOREIGN KEY(id_pelicula) 
        REFERENCES peliculas(id) ON DELETE CASCADE;
DELETE FROM peliculas
    WHERE estreno = 2008;
ROLLBACK;

-- 16. Inserte 2 actores para cada película estrenada el 2001.
BEGIN TRANSACTION;
INSERT INTO reparto (id_pelicula, actor)
	SELECT id, 'Juan Oh1'
        FROM peliculas AS p WHERE p.estreno = 2001;
INSERT INTO reparto (id_pelicula, actor)
	SELECT id, 'Juan Oh2'
        FROM peliculas AS p WHERE p.estreno = 2001;
COMMIT;

-- 17. Actualice la película “King Kong” por el nombre de “Donkey Kong”, sin efectuar cambios en
-- disco duro.
BEGIN TRANSACTION;
UPDATE peliculas
    SET pelicula = 'Donkey Kong'
        WHERE pelicula = 'King Kong';
ROLLBACK;