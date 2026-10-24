-- Du lieu mau (sinh tu gen_seed.py)
SET NAMES utf8mb4;

INSERT INTO categories (name, description) VALUES
  ('Món nước', 'Phở, bún, canh và các món có nước dùng'),
  ('Món cơm', 'Các món ăn kèm cơm trắng, cơm tấm'),
  ('Món cuốn & gỏi', 'Món cuốn, gỏi tươi mát'),
  ('Món nướng – chiên', 'Món nướng, chiên giòn'),
  ('Tráng miệng', 'Chè và món ngọt');

INSERT INTO ingredients (name) VALUES
  ('Xương ống bò'),
  ('Thịt bò thăn'),
  ('Bánh phở'),
  ('Gừng'),
  ('Hành tây'),
  ('Quế'),
  ('Hoa hồi'),
  ('Nước mắm'),
  ('Hành lá'),
  ('Cá lóc'),
  ('Me chua'),
  ('Cà chua'),
  ('Dứa'),
  ('Đậu bắp'),
  ('Giá đỗ'),
  ('Bạc hà'),
  ('Rau om'),
  ('Đường'),
  ('Sườn cốt lết'),
  ('Cơm tấm'),
  ('Sả'),
  ('Tỏi'),
  ('Mật ong'),
  ('Trứng gà'),
  ('Dưa leo'),
  ('Thịt ba chỉ'),
  ('Trứng vịt'),
  ('Nước dừa tươi'),
  ('Hành tím'),
  ('Tiêu'),
  ('Bánh tráng'),
  ('Tôm'),
  ('Bún tươi'),
  ('Xà lách'),
  ('Húng quế'),
  ('Tương hột'),
  ('Đậu phộng rang'),
  ('Thịt vai heo xay'),
  ('Đu đủ xanh'),
  ('Rau sống'),
  ('Bột gạo'),
  ('Bột nghệ'),
  ('Nước cốt dừa'),
  ('Rau cải'),
  ('Đậu xanh cà vỏ'),
  ('Lá dứa'),
  ('Bột năng');

-- Phở bò Hà Nội
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Phở bò Hà Nội', 'Nước dùng trong, ngọt thanh từ xương bò hầm cùng quế, hồi, gừng nướng.', 'Chần xương bò qua nước sôi 5 phút, rửa sạch.
Nướng gừng và hành tây đến khi thơm, cạo sạch vỏ.
Cho xương, gừng, hành, quế, hồi vào nồi cùng 4 lít nước, hầm nhỏ lửa 3 giờ, thường xuyên vớt bọt.
Nêm nước mắm, muối cho vừa miệng.
Trụng bánh phở, xếp thịt bò thái mỏng lên trên, chan nước dùng thật nóng.
Thêm hành lá, ăn kèm chanh, ớt, quẩy.', 180, 4, 'hard', (SELECT id FROM categories WHERE name='Món nước'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Xương ống bò'), '1 kg'),
  (@rid, (SELECT id FROM ingredients WHERE name='Thịt bò thăn'), '300 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Bánh phở'), '500 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Gừng'), '1 củ lớn'),
  (@rid, (SELECT id FROM ingredients WHERE name='Hành tây'), '2 củ'),
  (@rid, (SELECT id FROM ingredients WHERE name='Quế'), '1 thanh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Hoa hồi'), '3 cánh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước mắm'), '3 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Hành lá'), '3 cây');

-- Canh chua cá lóc
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Canh chua cá lóc', 'Vị chua thanh của me, thơm ngát rau om, ngò gai – món canh quen thuộc miền Tây.', 'Cá lóc làm sạch, cắt khúc, ướp chút muối và tiêu.
Đun sôi 1,5 lít nước, cho nước cốt me, cà chua, dứa vào nấu 5 phút.
Thả cá vào nấu chín, nêm nước mắm và đường.
Cho đậu bắp, bạc hà, giá đỗ vào, tắt bếp sau 1 phút.
Rắc rau om, ngò gai và ăn nóng với cơm trắng.', 40, 4, 'medium', (SELECT id FROM categories WHERE name='Món nước'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Cá lóc'), '500 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Me chua'), '2 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Cà chua'), '2 quả'),
  (@rid, (SELECT id FROM ingredients WHERE name='Dứa'), '1/4 quả'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đậu bắp'), '4 trái'),
  (@rid, (SELECT id FROM ingredients WHERE name='Giá đỗ'), '100 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Bạc hà'), '2 cây'),
  (@rid, (SELECT id FROM ingredients WHERE name='Rau om'), '1 nắm'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước mắm'), '2 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đường'), '1 muỗng canh');

-- Cơm tấm sườn nướng
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Cơm tấm sườn nướng', 'Sườn nướng mật ong thơm lừng ăn kèm cơm tấm, trứng ốp la và đồ chua.', 'Ướp sườn với sả, tỏi băm, mật ong, nước mắm trong ít nhất 2 giờ.
Nướng sườn trên than hoặc lò 200°C khoảng 20–25 phút, trở mặt đều.
Nấu cơm tấm, chiên trứng ốp la.
Dọn cơm cùng sườn, trứng, dưa leo, cà chua.
Rưới nước mắm chua ngọt và thưởng thức.', 60, 2, 'medium', (SELECT id FROM categories WHERE name='Món cơm'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Sườn cốt lết'), '400 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Cơm tấm'), '2 chén'),
  (@rid, (SELECT id FROM ingredients WHERE name='Sả'), '3 cây'),
  (@rid, (SELECT id FROM ingredients WHERE name='Tỏi'), '4 tép'),
  (@rid, (SELECT id FROM ingredients WHERE name='Mật ong'), '2 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước mắm'), '2 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Trứng gà'), '2 quả'),
  (@rid, (SELECT id FROM ingredients WHERE name='Dưa leo'), '1 quả'),
  (@rid, (SELECT id FROM ingredients WHERE name='Cà chua'), '1 quả');

-- Thịt kho trứng
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Thịt kho trứng', 'Thịt ba chỉ kho mềm cùng trứng, nước màu cánh gián đậm đà đưa cơm.', 'Luộc trứng, bóc vỏ. Thịt cắt miếng vuông 3 cm, ướp nước mắm, hành tím, tiêu 30 phút.
Thắng đường thành nước màu cánh gián, cho thịt vào đảo săn.
Đổ nước dừa ngập thịt, đun sôi rồi hạ lửa nhỏ.
Sau 40 phút cho trứng vào kho thêm 30 phút đến khi nước sánh.
Nêm lại vừa ăn, dùng nóng với cơm trắng và dưa chua.', 90, 4, 'easy', (SELECT id FROM categories WHERE name='Món cơm'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Thịt ba chỉ'), '600 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Trứng vịt'), '6 quả'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước dừa tươi'), '500 ml'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước mắm'), '3 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đường'), '2 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Hành tím'), '3 củ'),
  (@rid, (SELECT id FROM ingredients WHERE name='Tiêu'), '1/2 muỗng cà phê');

-- Gỏi cuốn tôm thịt
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Gỏi cuốn tôm thịt', 'Cuốn tươi mát với tôm, thịt luộc, bún và rau thơm, chấm tương đậu phộng.', 'Luộc tôm và thịt, để nguội rồi cắt lát mỏng, bóc vỏ tôm.
Rửa rau, để ráo.
Nhúng nhanh bánh tráng vào nước, trải ra đĩa.
Xếp rau, bún, thịt, tôm rồi cuộn chặt tay.
Pha tương hột với đậu phộng giã nhỏ và chút đường làm nước chấm.', 35, 4, 'easy', (SELECT id FROM categories WHERE name='Món cuốn & gỏi'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Bánh tráng'), '12 tờ'),
  (@rid, (SELECT id FROM ingredients WHERE name='Tôm'), '300 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Thịt ba chỉ'), '200 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Bún tươi'), '200 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Xà lách'), '1 bó'),
  (@rid, (SELECT id FROM ingredients WHERE name='Húng quế'), '1 nắm'),
  (@rid, (SELECT id FROM ingredients WHERE name='Tương hột'), '3 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đậu phộng rang'), '3 muỗng canh');

-- Bún chả Hà Nội
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Bún chả Hà Nội', 'Chả viên và thịt nướng than hoa, ăn cùng bún và nước mắm chua ngọt.', 'Ướp thịt với hành tím băm, nước mắm, đường, tiêu trong 1 giờ.
Nặn thịt xay thành viên dẹt, ba chỉ để nguyên lát.
Nướng chả và thịt trên than đến khi vàng xém thơm.
Pha nước chấm: nước mắm, đường, giấm, tỏi ớt, thêm đu đủ ngâm.
Thả chả vào bát nước chấm, ăn cùng bún và rau sống.', 75, 3, 'medium', (SELECT id FROM categories WHERE name='Món nướng – chiên'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Thịt vai heo xay'), '300 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Thịt ba chỉ'), '300 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Bún tươi'), '500 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Hành tím'), '3 củ'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước mắm'), '4 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đường'), '3 muỗng canh'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đu đủ xanh'), '1/2 quả'),
  (@rid, (SELECT id FROM ingredients WHERE name='Rau sống'), '1 đĩa');

-- Bánh xèo miền Tây
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Bánh xèo miền Tây', 'Vỏ bánh giòn rụm vàng ươm, nhân tôm thịt giá đỗ, cuốn rau cải chấm nước mắm.', 'Trộn bột gạo, bột nghệ, nước cốt dừa, hành lá và 300 ml nước, để nghỉ 30 phút.
Xào sơ tôm, thịt ba chỉ cắt mỏng.
Làm nóng chảo, tráng một lớp bột mỏng, cho tôm thịt, giá đỗ lên trên.
Đậy nắp 2 phút rồi mở nắp chiên đến khi vỏ giòn, gập đôi.
Cuốn bánh với rau cải, chấm nước mắm chua ngọt.', 50, 4, 'medium', (SELECT id FROM categories WHERE name='Món nướng – chiên'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Bột gạo'), '200 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Bột nghệ'), '1 muỗng cà phê'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước cốt dừa'), '200 ml'),
  (@rid, (SELECT id FROM ingredients WHERE name='Tôm'), '200 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Thịt ba chỉ'), '200 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Giá đỗ'), '150 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Hành lá'), '3 cây'),
  (@rid, (SELECT id FROM ingredients WHERE name='Rau cải'), '1 bó'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước mắm'), '3 muỗng canh');

-- Chè đậu xanh
INSERT INTO recipes (title, description, steps, cook_time, servings, difficulty, category_id) VALUES ('Chè đậu xanh', 'Chè đậu xanh nhuyễn mịn, ngọt dịu, thơm mùi lá dứa, ăn nóng hoặc lạnh đều ngon.', 'Ngâm đậu xanh 2 giờ, vo sạch, để ráo.
Nấu đậu với 1 lít nước và lá dứa đến khi đậu nhừ.
Cho đường vào, khuấy đều, nêm vừa ngọt.
Hòa bột năng với nước, đổ từ từ vào để chè sánh nhẹ.
Múc ra chén, rưới nước cốt dừa và thưởng thức.', 45, 4, 'easy', (SELECT id FROM categories WHERE name='Tráng miệng'));
SET @rid = LAST_INSERT_ID();
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES
  (@rid, (SELECT id FROM ingredients WHERE name='Đậu xanh cà vỏ'), '200 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Đường'), '100 g'),
  (@rid, (SELECT id FROM ingredients WHERE name='Lá dứa'), '3 lá'),
  (@rid, (SELECT id FROM ingredients WHERE name='Nước cốt dừa'), '100 ml'),
  (@rid, (SELECT id FROM ingredients WHERE name='Bột năng'), '1 muỗng canh');
