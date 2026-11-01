CREATE TABLE geography.counties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  county_code VARCHAR(10) NOT NULL UNIQUE,
  county_name VARCHAR(100) NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO geography.counties(county_code,county_name) VALUES
('001','Mombasa'),('002','Kwale'),('003','Kilifi'),('004','Tana River'),
('005','Lamu'),('006','Taita-Taveta'),('007','Garissa'),('008','Wajir'),
('009','Mandera'),('010','Marsabit'),('011','Isiolo'),('012','Meru'),
('013','Tharaka-Nithi'),('014','Embu'),('015','Kitui'),('016','Machakos'),
('017','Makueni'),('018','Nyandarua'),('019','Nyeri'),('020','Kirinyaga'),
('021','Murang''a'),('022','Kiambu'),('023','Turkana'),('024','West Pokot'),
('025','Samburu'),('026','Trans Nzoia'),('027','Uasin Gishu'),('028','Elgeyo-Marakwet'),
('029','Nandi'),('030','Baringo'),('031','Laikipia'),('032','Nakuru'),
('033','Narok'),('034','Kajiado'),('035','Kericho'),('036','Bomet'),
('037','Kakamega'),('038','Vihiga'),('039','Bungoma'),('040','Busia'),
('041','Siaya'),('042','Kisumu'),('043','Homa Bay'),('044','Migori'),
('045','Kisii'),('046','Nyamira'),('047','Nairobi');
