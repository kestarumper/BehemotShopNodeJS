-- phpMyAdmin SQL Dump
-- version 4.6.6deb4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Czas generowania: 13 Sty 2018, 00:14
-- Wersja serwera: 5.7.20-0ubuntu0.17.04.1
-- Wersja PHP: 7.0.22-0ubuntu0.17.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `behemoth`
--
CREATE DATABASE IF NOT EXISTS `behemoth` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `behemoth`;

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addCustomerAddress` (IN `id_customer` INT(10), IN `id_address` INT(10))  NO SQL
INSERT INTO customeraddresses VALUES (id_customer, id_address)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addDiscount` (IN `id_customer` INT(10))  NO SQL
INSERT INTO discounts VALUES (id_customer, 0.05)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addNewCustomerAddress` (IN `city` VARCHAR(128), IN `street` VARCHAR(128), IN `number` INT(10), IN `postalcode` CHAR(6), IN `country` VARCHAR(128), IN `id_customer` INT(10))  MODIFIES SQL DATA
BEGIN

	START TRANSACTION;
    BEGIN
		IF ((SELECT COUNT(1) FROM addresses AS A WHERE A.city = city AND A.street = street AND A.number=number AND A.postalcode=postalcode AND A.country=country) = 1) THEN 
			CALL addCustomerAddress(id_customer,(SELECT id_address FROM addresses AS A WHERE A.city = city AND A.street = street AND A.number=number AND A.postalcode=postalcode AND A.country=country));
	ELSE
			INSERT INTO addresses (city, street, number, postalcode, country) VALUES (city, street, number, postalcode, country);
    		CALL addCustomerAddress(id_customer,(SELECT id_address FROM addresses AS A WHERE A.city = city AND A.street = street AND A.number=number AND A.postalcode=postalcode AND A.country=country));
		END IF;
    	COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prepareOrder` (IN `whoOrders` INT(10), IN `whereOrders` INT(10), IN `paymentMethod` ENUM('Card','Cash','Transfer'), IN `phoneNumber` INT(9), IN `listOfProducts` VARCHAR(128))  NO SQL
BEGIN
DECLARE pom VARCHAR(128);
DECLARE numer INT(2) DEFAULT 1;
    
    IF((SELECT CHARACTER_LENGTH(listOfProducts))=0) THEN
		SIGNAL SQLSTATE '44444' SET MESSAGE_TEXT = "Your cart is empty"; 
	ELSEIF((SELECT COUNT(1) FROM customer WHERE customer.id_customer=whoOrders)=0) THEN
    	SIGNAL SQLSTATE '44444' SET MESSAGE_TEXT = "There is no such client";
    ELSEIF((SELECT COUNT(1) FROM addresses WHERE addresses.id_address=whereOrders)=0) THEN
    	SIGNAL SQLSTATE '44444' SET MESSAGE_TEXT = "There is no such address"; 
    END IF;
    
    START TRANSACTION;
    BEGIN
    	INSERT INTO orders (id_customer, id_address, order_date, status, payment_method, phone) VALUES (whoOrders, whereOrders, CURDATE(), 'pending', paymentMethod, phoneNumber);
    	WHILE((SELECT CHAR_LENGTH(listOfProducts))>pom) DO
        	INSERT INTO orderitem (id_order, item_name, quantity)VALUES ((SELECT id_order FROM orders WHERE orders.id_customer=whoOrders AND orders.status='pending'), (SELECT SUBSTRING_INDEX((SELECT SUBSTRING_INDEX(listOfProducts, ', ', numer)),', ',-1)), 1);
            SET pom=pom+2+(  SELECT CHAR_LENGTH((SELECT SUBSTRING_INDEX((SELECT SUBSTRING_INDEX(listOfProducts, ', ', numer)),', ',-1)))  );
        END WHILE;
        UPDATE orders SET orders.status='order completed' WHERE orders.status='pending' AND orders.id_customer=whoOrders;
        COMMIT;
    END;    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerNewCustomerWithAddress` (IN `email` VARCHAR(128), IN `name` VARCHAR(128), IN `surname` VARCHAR(128), IN `password` VARCHAR(128), IN `newsletter` BIT, IN `city` VARCHAR(128), IN `street` VARCHAR(128), IN `houseNumber` INT(10), IN `postalCode` CHAR(6), IN `country` VARCHAR(128))  NO SQL
BEGIN

	START TRANSACTION;
    BEGIN
		IF((SELECT COUNT(1) FROM customer WHERE customer.email=email)=1)
        THEN
			SIGNAL SQLSTATE '44444' SET MESSAGE_TEXT = "Account with such email already exists";
		ELSE
			INSERT INTO customer (email, `name`, `surname`, `password`, registered_date, newsletter) VALUES (email, name, surname, `password`, CURDATE(), newsletter);
		CALL addNewCustomerAddress(city, street, houseNumber, postalCode, country, (SELECT id_customer FROM customer WHERE customer.email=email));
		END IF;
		COMMIT;
    END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateItem` (IN `name` VARCHAR(128), IN `price` DECIMAL(10,2), IN `category` VARCHAR(128), IN `num_of_items` INT(10), IN `image` VARCHAR(128))  NO SQL
UPDATE items SET items.name=name, items.price=price, items.category=category, items.num_of_items=num_of_items, items.image=image$$

--
-- Funkcje
--
CREATE DEFINER=`root`@`localhost` FUNCTION `checkIfProductsAreAvailable` (`itemName` VARCHAR(128), `number` INT(10)) RETURNS TINYINT(1) READS SQL DATA
IF((SELECT num_of_items FROM items WHERE items.name=itemName)>=number) THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `addresses`
--

CREATE TABLE `addresses` (
  `id_address` int(10) NOT NULL,
  `city` varchar(128) NOT NULL,
  `street` varchar(128) NOT NULL,
  `number` int(10) NOT NULL,
  `postalcode` char(6) NOT NULL,
  `country` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `addresses`
--

INSERT INTO `addresses` (`id_address`, `city`, `street`, `number`, `postalcode`, `country`) VALUES
(1, 'Siemianowice', 'ul. Podwawelska', 56, '24-350', 'Poland');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `customer`
--

CREATE TABLE `customer` (
  `id_customer` int(10) NOT NULL,
  `email` varchar(128) NOT NULL,
  `name` varchar(128) NOT NULL,
  `surname` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  `registered_date` date NOT NULL,
  `newsletter` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `customer`
--

INSERT INTO `customer` (`id_customer`, `email`, `name`, `surname`, `password`, `registered_date`, `newsletter`) VALUES
(1, 'testowy@gmail.com', 'Janusz', 'Kowalski', '$2a$10$fNUPTpbp92pth3r9m3q7heXWVXHELWKIxp5gQc74.Gou2BjqP0Qw6', '2018-01-12', b'1');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `customeraddresses`
--

CREATE TABLE `customeraddresses` (
  `id_customer` int(10) NOT NULL,
  `id_address` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `customeraddresses`
--

INSERT INTO `customeraddresses` (`id_customer`, `id_address`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `discounts`
--

CREATE TABLE `discounts` (
  `id_customer` int(10) NOT NULL,
  `height` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `items`
--

CREATE TABLE `items` (
  `name` varchar(128) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `category` varchar(128) NOT NULL,
  `num_of_items` int(10) NOT NULL,
  `image` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Zrzut danych tabeli `items`
--

INSERT INTO `items` (`name`, `price`, `category`, `num_of_items`, `image`) VALUES
('buty 1', '263.00', 'buty', 246, 'http://dummyimage.com/245x183.jpg/5fa2dd/ffffff'),
('buty 10', '194.00', 'buty', 655, 'http://dummyimage.com/195x231.jpg/dddddd/000000'),
('buty 13', '153.00', 'buty', 287, 'http://dummyimage.com/120x135.jpg/cc0000/ffffff'),
('buty 15', '118.00', 'buty', 671, 'http://dummyimage.com/125x181.jpg/ff4444/ffffff'),
('buty 16', '143.00', 'buty', 597, 'http://dummyimage.com/117x169.jpg/dddddd/000000'),
('buty 19', '285.00', 'buty', 312, 'http://dummyimage.com/137x192.jpg/dddddd/000000'),
('buty 2', '125.00', 'buty', 534, 'http://dummyimage.com/152x246.jpg/dddddd/000000'),
('buty 21', '270.00', 'buty', 946, 'http://dummyimage.com/194x123.jpg/dddddd/000000'),
('buty 23', '202.00', 'buty', 804, 'http://dummyimage.com/225x151.jpg/dddddd/000000'),
('buty 25', '194.00', 'buty', 655, 'http://dummyimage.com/151x112.jpg/cc0000/ffffff'),
('buty 28', '185.00', 'buty', 134, 'http://dummyimage.com/120x205.jpg/ff4444/ffffff'),
('buty 30', '93.00', 'buty', 469, 'http://dummyimage.com/162x222.jpg/cc0000/ffffff'),
('buty 31', '80.00', 'buty', 616, 'http://dummyimage.com/213x211.jpg/cc0000/ffffff'),
('buty 32', '266.00', 'buty', 447, 'http://dummyimage.com/160x158.jpg/dddddd/000000'),
('buty 34', '239.00', 'buty', 662, 'http://dummyimage.com/215x143.jpg/cc0000/ffffff'),
('buty 35', '261.00', 'buty', 107, 'http://dummyimage.com/176x228.jpg/ff4444/ffffff'),
('buty 36', '201.00', 'buty', 562, 'http://dummyimage.com/167x127.jpg/dddddd/000000'),
('buty 37', '173.00', 'buty', 786, 'http://dummyimage.com/210x125.jpg/ff4444/ffffff'),
('buty 39', '186.00', 'buty', 656, 'http://dummyimage.com/169x198.jpg/dddddd/000000'),
('buty 41', '208.00', 'buty', 604, 'http://dummyimage.com/139x144.jpg/cc0000/ffffff'),
('buty 42', '252.00', 'buty', 689, 'http://dummyimage.com/201x175.jpg/5fa2dd/ffffff'),
('buty 45', '121.00', 'buty', 234, 'http://dummyimage.com/164x152.jpg/ff4444/ffffff'),
('buty 48', '221.00', 'buty', 163, 'http://dummyimage.com/150x158.jpg/ff4444/ffffff'),
('buty 49', '111.00', 'buty', 961, 'http://dummyimage.com/220x177.jpg/cc0000/ffffff'),
('buty 4Runner', '97.00', 'buty', 806, 'http://dummyimage.com/235x112.jpg/cc0000/ffffff'),
('buty 51', '103.00', 'buty', 435, 'http://dummyimage.com/142x242.jpg/5fa2dd/ffffff'),
('buty 52', '208.00', 'buty', 757, 'http://dummyimage.com/151x231.jpg/cc0000/ffffff'),
('buty 53', '218.00', 'buty', 783, 'http://dummyimage.com/215x186.jpg/ff4444/ffffff'),
('buty 55', '120.00', 'buty', 424, 'http://dummyimage.com/141x149.jpg/cc0000/ffffff'),
('buty 59', '166.00', 'buty', 130, 'http://dummyimage.com/168x127.jpg/ff4444/ffffff'),
('buty 60', '101.00', 'buty', 446, 'http://dummyimage.com/212x184.jpg/cc0000/ffffff'),
('buty 61', '239.00', 'buty', 287, 'http://dummyimage.com/134x211.jpg/cc0000/ffffff'),
('buty 66', '168.00', 'buty', 259, 'http://dummyimage.com/229x241.jpg/5fa2dd/ffffff'),
('buty 69', '53.00', 'buty', 897, 'http://dummyimage.com/187x218.jpg/dddddd/000000'),
('buty 7', '89.00', 'buty', 602, 'http://dummyimage.com/175x133.jpg/ff4444/ffffff'),
('buty 72', '171.00', 'buty', 967, 'http://dummyimage.com/202x111.jpg/dddddd/000000'),
('buty 73', '253.00', 'buty', 248, 'http://dummyimage.com/233x138.jpg/cc0000/ffffff'),
('buty 74', '267.00', 'buty', 854, 'http://dummyimage.com/217x142.jpg/dddddd/000000'),
('buty 75', '154.00', 'buty', 278, 'http://dummyimage.com/213x207.jpg/ff4444/ffffff'),
('buty 77', '210.00', 'buty', 785, 'http://dummyimage.com/183x215.jpg/cc0000/ffffff'),
('buty 8', '138.00', 'buty', 554, 'http://dummyimage.com/170x240.jpg/ff4444/ffffff'),
('buty 80', '259.00', 'buty', 437, 'http://dummyimage.com/119x132.jpg/dddddd/000000'),
('buty 82', '181.00', 'buty', 316, 'http://dummyimage.com/193x238.jpg/cc0000/ffffff'),
('buty 84', '201.00', 'buty', 115, 'http://dummyimage.com/153x207.jpg/5fa2dd/ffffff'),
('buty 88', '46.00', 'buty', 953, 'http://dummyimage.com/155x138.jpg/5fa2dd/ffffff'),
('buty 89', '53.00', 'buty', 505, 'http://dummyimage.com/186x228.jpg/ff4444/ffffff'),
('buty 90', '247.00', 'buty', 987, 'http://dummyimage.com/157x101.jpg/dddddd/000000'),
('buty 93', '90.00', 'buty', 833, 'http://dummyimage.com/164x229.jpg/dddddd/000000'),
('buty 94', '38.00', 'buty', 408, 'http://dummyimage.com/174x183.jpg/ff4444/ffffff'),
('buty 95', '168.00', 'buty', 732, 'http://dummyimage.com/199x154.jpg/dddddd/000000'),
('buty 98', '137.00', 'buty', 826, 'http://dummyimage.com/126x190.jpg/5fa2dd/ffffff'),
('buty Bravada', '230.00', 'buty', 773, 'http://dummyimage.com/138x232.jpg/cc0000/ffffff'),
('buty Civic Si', '232.00', 'buty', 350, 'http://dummyimage.com/114x189.jpg/dddddd/000000'),
('buty Club Wagon', '265.00', 'buty', 852, 'http://dummyimage.com/226x199.jpg/5fa2dd/ffffff'),
('buty Colorado', '100.00', 'buty', 330, 'http://dummyimage.com/164x175.jpg/ff4444/ffffff'),
('buty Defender 90', '154.00', 'buty', 770, 'http://dummyimage.com/158x142.jpg/5fa2dd/ffffff'),
('buty Defender Ice Edition', '115.00', 'buty', 171, 'http://dummyimage.com/193x227.jpg/ff4444/ffffff'),
('buty ES', '260.00', 'buty', 927, 'http://dummyimage.com/197x173.jpg/cc0000/ffffff'),
('buty Escalade ESV', '54.00', 'buty', 188, 'http://dummyimage.com/245x204.jpg/cc0000/ffffff'),
('buty Explorer', '142.00', 'buty', 803, 'http://dummyimage.com/248x223.jpg/ff4444/ffffff'),
('buty Explorer Sport Trac', '226.00', 'buty', 462, 'http://dummyimage.com/103x233.jpg/ff4444/ffffff'),
('buty Grand Prix', '118.00', 'buty', 829, 'http://dummyimage.com/220x122.jpg/ff4444/ffffff'),
('buty GTI', '114.00', 'buty', 795, 'http://dummyimage.com/250x207.jpg/cc0000/ffffff'),
('buty Hombre Space', '217.00', 'buty', 863, 'http://dummyimage.com/223x235.jpg/ff4444/ffffff'),
('buty Matrix', '70.00', 'buty', 455, 'http://dummyimage.com/107x126.jpg/cc0000/ffffff'),
('buty Murciélago', '256.00', 'buty', 935, 'http://dummyimage.com/174x181.jpg/dddddd/000000'),
('buty Quest', '299.00', 'buty', 365, 'http://dummyimage.com/134x175.jpg/cc0000/ffffff'),
('buty Ridgeline', '284.00', 'buty', 968, 'http://dummyimage.com/114x208.jpg/5fa2dd/ffffff'),
('buty S-Type', '180.00', 'buty', 544, 'http://dummyimage.com/247x185.jpg/dddddd/000000'),
('buty Santa Fe', '212.00', 'buty', 654, 'http://dummyimage.com/149x233.jpg/5fa2dd/ffffff'),
('buty Savana 2500', '156.00', 'buty', 394, 'http://dummyimage.com/102x228.jpg/5fa2dd/ffffff'),
('buty Spirit', '292.00', 'buty', 587, 'http://dummyimage.com/112x123.jpg/dddddd/000000'),
('buty Sprinter', '161.00', 'buty', 867, 'http://dummyimage.com/172x135.jpg/5fa2dd/ffffff'),
('buty tC', '137.00', 'buty', 680, 'http://dummyimage.com/139x117.jpg/cc0000/ffffff'),
('buty Truck', '272.00', 'buty', 617, 'http://dummyimage.com/219x225.jpg/5fa2dd/ffffff'),
('buty Voyager', '59.00', 'buty', 433, 'http://dummyimage.com/209x209.jpg/dddddd/000000'),
('buty X-Type', '109.00', 'buty', 849, 'http://dummyimage.com/101x159.jpg/5fa2dd/ffffff'),
('koszula 100', '133.00', 'koszule', 564, 'http://dummyimage.com/166x213.jpg/ff4444/ffffff'),
('koszula 14', '66.00', 'koszule', 883, 'http://dummyimage.com/213x172.jpg/dddddd/000000'),
('koszula 22', '213.00', 'koszule', 415, 'http://dummyimage.com/246x141.jpg/cc0000/ffffff'),
('koszula 27', '259.00', 'koszule', 643, 'http://dummyimage.com/225x138.jpg/5fa2dd/ffffff'),
('koszula 29', '34.00', 'koszule', 562, 'http://dummyimage.com/214x144.jpg/dddddd/000000'),
('koszula 43', '143.00', 'koszule', 683, 'http://dummyimage.com/124x180.jpg/5fa2dd/ffffff'),
('koszula 47', '204.00', 'koszule', 887, 'http://dummyimage.com/235x104.jpg/5fa2dd/ffffff'),
('koszula 5', '26.00', 'koszule', 113, 'http://dummyimage.com/119x162.jpg/5fa2dd/ffffff'),
('koszula 6', '212.00', 'koszule', 201, 'http://dummyimage.com/151x109.jpg/ff4444/ffffff'),
('koszula 78', '117.00', 'koszule', 884, 'http://dummyimage.com/126x159.jpg/dddddd/000000'),
('koszula 99', '95.00', 'koszule', 379, 'http://dummyimage.com/168x224.jpg/5fa2dd/ffffff'),
('koszula Azure', '21.00', 'koszule', 123, 'http://dummyimage.com/140x229.jpg/5fa2dd/ffffff'),
('koszula Escape', '284.00', 'koszule', 333, 'http://dummyimage.com/143x172.jpg/cc0000/ffffff'),
('koszula Sonata', '66.00', 'koszule', 188, 'http://dummyimage.com/226x179.jpg/ff4444/ffffff'),
('koszula Touareg', '52.00', 'koszule', 589, 'http://dummyimage.com/145x226.jpg/ff4444/ffffff'),
('plecak 26', '22.00', 'torby i plecaki', 582, 'http://dummyimage.com/219x199.jpg/ff4444/ffffff'),
('plecak 54', '199.00', 'torby i plecaki', 497, 'http://dummyimage.com/243x227.jpg/5fa2dd/ffffff'),
('plecak 62', '232.00', 'torby i plecaki', 112, 'http://dummyimage.com/153x218.jpg/cc0000/ffffff'),
('plecak 91', '194.00', 'torby i plecaki', 568, 'http://dummyimage.com/185x111.jpg/dddddd/000000'),
('plecak Axiom', '258.00', 'torby i plecaki', 584, 'http://dummyimage.com/172x241.jpg/dddddd/000000'),
('plecak E-Series', '92.00', 'torby i plecaki', 693, 'http://dummyimage.com/188x206.jpg/5fa2dd/ffffff'),
('plecak Thunderbird', '297.00', 'torby i plecaki', 467, 'http://dummyimage.com/239x186.jpg/5fa2dd/ffffff'),
('spódnica 18', '151.00', 'spódnice i sukienki', 930, 'http://dummyimage.com/150x248.jpg/cc0000/ffffff'),
('spódnica 71', '94.00', 'spódnice i sukienki', 605, 'http://dummyimage.com/201x153.jpg/ff4444/ffffff'),
('spódnica M', '173.00', 'spódnice i sukienki', 437, 'http://dummyimage.com/248x245.jpg/ff4444/ffffff'),
('spodnie 11', '74.00', 'spodnie', 257, 'http://dummyimage.com/249x131.jpg/5fa2dd/ffffff'),
('spodnie 12', '49.00', 'spodnie', 369, 'http://dummyimage.com/121x205.jpg/dddddd/000000'),
('spodnie 17', '285.00', 'spodnie', 762, 'http://dummyimage.com/197x138.jpg/dddddd/000000'),
('spodnie 20', '252.00', 'spodnie', 322, 'http://dummyimage.com/194x120.jpg/ff4444/ffffff'),
('spodnie 24', '282.00', 'spodnie', 266, 'http://dummyimage.com/206x119.jpg/cc0000/ffffff'),
('spodnie 3', '156.00', 'spodnie', 759, 'http://dummyimage.com/183x226.jpg/cc0000/ffffff'),
('spodnie 33', '175.00', 'spodnie', 811, 'http://dummyimage.com/184x136.jpg/cc0000/ffffff'),
('spodnie 350Z', '266.00', 'spodnie', 482, 'http://dummyimage.com/173x205.jpg/5fa2dd/ffffff'),
('spodnie 38', '69.00', 'spodnie', 454, 'http://dummyimage.com/135x239.jpg/5fa2dd/ffffff'),
('spodnie 4', '109.00', 'spodnie', 659, 'http://dummyimage.com/223x189.jpg/ff4444/ffffff'),
('spodnie 40', '270.00', 'spodnie', 226, 'http://dummyimage.com/130x176.jpg/ff4444/ffffff'),
('spodnie 44', '53.00', 'spodnie', 203, 'http://dummyimage.com/207x185.jpg/cc0000/ffffff'),
('spodnie 46', '123.00', 'spodnie', 979, 'http://dummyimage.com/109x104.jpg/cc0000/ffffff'),
('spodnie 50', '47.00', 'spodnie', 106, 'http://dummyimage.com/117x155.jpg/5fa2dd/ffffff'),
('spodnie 56', '59.00', 'spodnie', 994, 'http://dummyimage.com/101x119.jpg/cc0000/ffffff'),
('spodnie 57', '25.00', 'spodnie', 414, 'http://dummyimage.com/110x187.jpg/dddddd/000000'),
('spodnie 58', '148.00', 'spodnie', 574, 'http://dummyimage.com/136x244.jpg/cc0000/ffffff'),
('spodnie 63', '249.00', 'spodnie', 372, 'http://dummyimage.com/158x166.jpg/dddddd/000000'),
('spodnie 64', '263.00', 'spodnie', 319, 'http://dummyimage.com/141x106.jpg/cc0000/ffffff'),
('spodnie 65', '82.00', 'spodnie', 685, 'http://dummyimage.com/135x246.jpg/5fa2dd/ffffff'),
('spodnie 67', '99.00', 'spodnie', 872, 'http://dummyimage.com/181x149.jpg/cc0000/ffffff'),
('spodnie 68', '196.00', 'spodnie', 489, 'http://dummyimage.com/228x150.jpg/cc0000/ffffff'),
('spodnie 70', '240.00', 'spodnie', 768, 'http://dummyimage.com/150x212.jpg/ff4444/ffffff'),
('spodnie 76', '43.00', 'spodnie', 388, 'http://dummyimage.com/156x108.jpg/dddddd/000000'),
('spodnie 79', '206.00', 'spodnie', 880, 'http://dummyimage.com/138x213.jpg/dddddd/000000'),
('spodnie 81', '289.00', 'spodnie', 495, 'http://dummyimage.com/187x105.jpg/cc0000/ffffff'),
('spodnie 83', '127.00', 'spodnie', 762, 'http://dummyimage.com/230x237.jpg/ff4444/ffffff'),
('spodnie 85', '117.00', 'spodnie', 406, 'http://dummyimage.com/133x148.jpg/ff4444/ffffff'),
('spodnie 86', '253.00', 'spodnie', 759, 'http://dummyimage.com/177x113.jpg/ff4444/ffffff'),
('spodnie 87', '272.00', 'spodnie', 410, 'http://dummyimage.com/162x119.jpg/dddddd/000000'),
('spodnie 9', '249.00', 'spodnie', 315, 'http://dummyimage.com/202x134.jpg/cc0000/ffffff'),
('spodnie 92', '105.00', 'spodnie', 977, 'http://dummyimage.com/209x150.jpg/ff4444/ffffff'),
('spodnie 96', '247.00', 'spodnie', 282, 'http://dummyimage.com/167x201.jpg/dddddd/000000'),
('spodnie 97', '263.00', 'spodnie', 172, 'http://dummyimage.com/105x122.jpg/ff4444/ffffff'),
('spodnie Cavalier', '166.00', 'spodnie', 282, 'http://dummyimage.com/197x157.jpg/cc0000/ffffff'),
('spodnie Corolla', '146.00', 'spodnie', 652, 'http://dummyimage.com/225x199.jpg/dddddd/000000'),
('spodnie FJ Cruiser', '216.00', 'spodnie', 488, 'http://dummyimage.com/134x231.jpg/5fa2dd/ffffff'),
('spodnie H1', '53.00', 'spodnie', 116, 'http://dummyimage.com/245x126.jpg/cc0000/ffffff'),
('spodnie Legacy', '147.00', 'spodnie', 909, 'http://dummyimage.com/141x144.jpg/dddddd/000000'),
('spodnie Mirage', '70.00', 'spodnie', 109, 'http://dummyimage.com/103x153.jpg/cc0000/ffffff'),
('spodnie QX', '237.00', 'spodnie', 439, 'http://dummyimage.com/241x195.jpg/ff4444/ffffff'),
('spodnie RAV4', '26.00', 'spodnie', 298, 'http://dummyimage.com/204x206.jpg/5fa2dd/ffffff'),
('spodnie Tiburon', '130.00', 'spodnie', 659, 'http://dummyimage.com/235x209.jpg/5fa2dd/ffffff'),
('spodnie X-90', '32.00', 'spodnie', 646, 'http://dummyimage.com/194x232.jpg/5fa2dd/ffffff');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `loglogins`
--

CREATE TABLE `loglogins` (
  `id_customer` int(10) NOT NULL,
  `whenLoggedIn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `type` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `orderitem`
--

CREATE TABLE `orderitem` (
  `id_order` int(10) NOT NULL,
  `item_name` varchar(128) NOT NULL,
  `quantity` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `orders`
--

CREATE TABLE `orders` (
  `id_customer` int(10) NOT NULL,
  `id_address` int(10) NOT NULL,
  `order_date` date NOT NULL,
  `status` varchar(128) NOT NULL,
  `payment_method` enum('Card','Cash','Transfer') NOT NULL,
  `phone` char(9) NOT NULL,
  `id_order` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `sessionloggedin`
--

CREATE TABLE `sessionloggedin` (
  `id_customer` int(10) NOT NULL,
  `token` varchar(128) NOT NULL,
  `expidration_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id_address`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id_customer`);

--
-- Indexes for table `customeraddresses`
--
ALTER TABLE `customeraddresses`
  ADD KEY `customeraddresses_ibfk_1` (`id_address`),
  ADD KEY `customeraddresses_ibfk_2` (`id_customer`);

--
-- Indexes for table `discounts`
--
ALTER TABLE `discounts`
  ADD KEY `id_customer` (`id_customer`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`name`);

--
-- Indexes for table `loglogins`
--
ALTER TABLE `loglogins`
  ADD KEY `id_customer` (`id_customer`);

--
-- Indexes for table `orderitem`
--
ALTER TABLE `orderitem`
  ADD KEY `item_name` (`item_name`),
  ADD KEY `orderitem_ibfk_1` (`id_order`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id_order`),
  ADD KEY `orders_ibfk_1` (`id_address`),
  ADD KEY `orders_ibfk_2` (`id_customer`);

--
-- Indexes for table `sessionloggedin`
--
ALTER TABLE `sessionloggedin`
  ADD KEY `id_customer` (`id_customer`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id_address` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT dla tabeli `customer`
--
ALTER TABLE `customer`
  MODIFY `id_customer` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT dla tabeli `orders`
--
ALTER TABLE `orders`
  MODIFY `id_order` int(10) NOT NULL AUTO_INCREMENT;
--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `customeraddresses`
--
ALTER TABLE `customeraddresses`
  ADD CONSTRAINT `customeraddresses_ibfk_1` FOREIGN KEY (`id_address`) REFERENCES `addresses` (`id_address`),
  ADD CONSTRAINT `customeraddresses_ibfk_2` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`);

--
-- Ograniczenia dla tabeli `discounts`
--
ALTER TABLE `discounts`
  ADD CONSTRAINT `discounts_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`);

--
-- Ograniczenia dla tabeli `loglogins`
--
ALTER TABLE `loglogins`
  ADD CONSTRAINT `loglogins_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`);

--
-- Ograniczenia dla tabeli `orderitem`
--
ALTER TABLE `orderitem`
  ADD CONSTRAINT `orderitem_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`),
  ADD CONSTRAINT `orderitem_ibfk_2` FOREIGN KEY (`item_name`) REFERENCES `items` (`name`);

--
-- Ograniczenia dla tabeli `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`id_address`) REFERENCES `addresses` (`id_address`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`);

--
-- Ograniczenia dla tabeli `sessionloggedin`
--
ALTER TABLE `sessionloggedin`
  ADD CONSTRAINT `sessionloggedin_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
