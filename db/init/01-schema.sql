-- Schema CSDL website cong thuc nau an (MySQL 8 / utf8mb4)
SET NAMES utf8mb4;

CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categories (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recipes (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(200) NOT NULL,
  description TEXT NULL,
  steps       TEXT NOT NULL,
  image_url   VARCHAR(500) NULL,
  cook_time   INT NOT NULL DEFAULT 30,
  servings    INT NOT NULL DEFAULT 2,
  difficulty  ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy',
  category_id INT NOT NULL,
  views       INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_recipes_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  INDEX idx_recipes_category (category_id),
  INDEX idx_recipes_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ingredients (
  id   INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recipe_ingredients (
  recipe_id     INT NOT NULL,
  ingredient_id INT NOT NULL,
  quantity      VARCHAR(100) NULL,
  PRIMARY KEY (recipe_id, ingredient_id),
  CONSTRAINT fk_ri_recipe     FOREIGN KEY (recipe_id)     REFERENCES recipes(id)     ON DELETE CASCADE,
  CONSTRAINT fk_ri_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
