PRAGMA foreign_keys = ON;

CREATE TABLE perms (
    id integer PRIMARY KEY,
    perm_name text NOT NULL
);

CREATE TABLE provincias (
    nprvnc text PRIMARY KEY,
    cdscrpcn text NOT NULL
);

CREATE TABLE roles (
    id integer PRIMARY KEY,
    role_name text NOT NULL,
    level integer NOT NULL,
	 UNIQUE(role_name)
);

CREATE TABLE roles_perms (
    id_role integer NOT NULL,
    id_perm integer NOT NULL,
	PRIMARY KEY (id_role, id_perm),
	CONSTRAINT roles_perms_perms_id_perm_fk FOREIGN KEY (id_perm) REFERENCES perms(id) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT roles_perms_roles_id_role_fk FOREIGN KEY (id_role) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE users (
    id integer PRIMARY KEY,
    username text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    password text NOT NULL,
    email text,
    role text NOT NULL,
    provincia text,
    survey_user text,
    is_locked boolean DEFAULT false NOT NULL,
	CONSTRAINT users_provincias_provincia_fk FOREIGN KEY (provincia) REFERENCES provincias(nprvnc) ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT users_roles_role_fk FOREIGN KEY (role) REFERENCES roles(role_name) ON UPDATE CASCADE ON DELETE RESTRICT
);


INSERT INTO provincias VALUES ('2', 'Ciudad Autónoma de Buenos Aires');
INSERT INTO provincias VALUES ('4', 'Conourbano Bonaerense');
INSERT INTO provincias VALUES ('6', 'Buenos Aires');
INSERT INTO provincias VALUES ('10', 'Catamarca');
INSERT INTO provincias VALUES ('14', 'Córdoba');
INSERT INTO provincias VALUES ('18', 'Corrientes');
INSERT INTO provincias VALUES ('22', 'Chaco');
INSERT INTO provincias VALUES ('26', 'Chubut');
INSERT INTO provincias VALUES ('30', 'Entre Ríos');
INSERT INTO provincias VALUES ('34', 'Formosa');
INSERT INTO provincias VALUES ('38', 'Jujuy');
INSERT INTO provincias VALUES ('42', 'La Pampa');
INSERT INTO provincias VALUES ('46', 'La Rioja');
INSERT INTO provincias VALUES ('50', 'Mendoza');
INSERT INTO provincias VALUES ('54', 'Misiones');
INSERT INTO provincias VALUES ('58', 'Neuquén');
INSERT INTO provincias VALUES ('62', 'Río Negro');
INSERT INTO provincias VALUES ('66', 'Salta');
INSERT INTO provincias VALUES ('70', 'San Juan');
INSERT INTO provincias VALUES ('74', 'San Luis');
INSERT INTO provincias VALUES ('78', 'Santa Cruz');
INSERT INTO provincias VALUES ('82', 'Santa Fe');
INSERT INTO provincias VALUES ('86', 'Santiago del Estero');
INSERT INTO provincias VALUES ('90', 'Tucuman');
INSERT INTO provincias VALUES ('94', 'Tierra del Fuego');


INSERT INTO roles VALUES (1, 'coordinador_nacional', 100);
INSERT INTO roles VALUES (2, 'utg_nacional', 80);
INSERT INTO roles VALUES (3, 'jefe_equipo_regional', 60);
INSERT INTO roles VALUES (4, 'supevisor_calidad_regional', 50);
INSERT INTO roles VALUES (5, 'coordinador', 40);
INSERT INTO roles VALUES (6, 'utg', 30);
INSERT INTO roles VALUES (7, 'jefe_equipo', 20);
INSERT INTO roles VALUES (8, 'supevisor_calidad', 10);

INSERT INTO perms VALUES (1, 'seguimiento_campo');
INSERT INTO perms VALUES (2, 'monitoreo_cobertura_gestion');
INSERT INTO perms VALUES (3, 'calidad');

INSERT INTO roles_perms (id_role,id_perm) VALUES (1, 1);
INSERT INTO roles_perms (id_role,id_perm) VALUES (1, 2);
INSERT INTO roles_perms (id_role,id_perm) VALUES (1, 3);
INSERT INTO roles_perms (id_role,id_perm) VALUES (2, 1);
INSERT INTO roles_perms (id_role,id_perm) VALUES (2, 2);
INSERT INTO roles_perms (id_role,id_perm) VALUES (3, 1);
INSERT INTO roles_perms (id_role,id_perm) VALUES (4, 3);
INSERT INTO roles_perms (id_role,id_perm) VALUES (5, 1);
INSERT INTO roles_perms (id_role,id_perm) VALUES (5, 2);
INSERT INTO roles_perms (id_role,id_perm) VALUES (5, 3);
INSERT INTO roles_perms (id_role,id_perm) VALUES (6, 1);
INSERT INTO roles_perms (id_role,id_perm) VALUES (6, 2);
INSERT INTO roles_perms (id_role,id_perm) VALUES (7, 1);
INSERT INTO roles_perms (id_role,id_perm) VALUES (8, 3);

CREATE UNIQUE INDEX perms_perm_name_uk ON perms (perm_name);
CREATE UNIQUE INDEX provincias_nprvnc_cdscrpcn_uk ON provincias(nprvnc, cdscrpcn);
CREATE UNIQUE INDEX roles_role_name_uk ON roles(role_name);
CREATE UNIQUE INDEX users_username_uk ON users(username);

INSERT INTO users VALUES (1, 'gman', 'He', 'Man', '3aedf4ff6b20a24414eb39e7555f3fa634289ea73151fc8d6ede3e25b2d441e0', 'gmanzano@example.com', 'coordinador_nacional', NULL, NULL, false);

INSERT INTO users VALUES (2, 'utgnac', 'Juan', 'Nacional', '54e0206df02b8732a2bc627e4329d3197ed527c484e1d5ed7b07e88ef463ef67', 'utgnac@example.com', 'utg', NULL, NULL, false);
INSERT INTO users VALUES (3, 'vari', 'Victoria', 'Ariadna', 'd7684eb3e282c37cc527db83a833d641e60d1586a16cd27153c2596cddcd2786', 'varinci@example.com', 'utg_nacional', NULL, NULL, false);
INSERT INTO users VALUES (4, 'pepedoce', 'Pepe', 'De la Doce', '54e0206df02b8732a2bc627e4329d3197ed527c484e1d5ed7b07e88ef463ef67', 'pdeladoce@example.com', 'jefe_equipo', '90', NULL, false);
INSERT INTO users VALUES (5, 'utgchaco', 'Juan', 'De la UTG', '520965ed0b0136f9aab379f78944245b098663ba697870412e9f98d38469a0d5', 'jdelautg@example.com', 'utg', '22', 'CH3gral', false);
INSERT INTO users VALUES (6, 'diegoefe', 'Diego', 'Efe', '187b127e11c2612473caf703dda15c328bf32fd1290272db6ad7fc4a248c0af4', 'diegoefe@example.com', 'coordinador', '4', NULL, false);
