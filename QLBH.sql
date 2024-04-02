CREATE DATABASE QLBH  
GO 

USE QLBH
GO

CREATE TABLE khachhang
(
	makh NVARCHAR(50) PRIMARY KEY ,
	tenkh NVARCHAR(50),
	diachi NVARCHAR(50),
	sdt INT, 
	loaikh NVARCHAR(50),
)
CREATE TABLE mathang
(
	mamh NVARCHAR(50) PRIMARY KEY,
	tenmh NVARCHAR(50),
	dvt NVARCHAR(50),
	gia INT,
)
CREATE TABLE hoadon
(
	mahd NVARCHAR(50) PRIMARY KEY,
	makh NVARCHAR(50),
	ngaylap DATE,
)
CREATE TABLE cthd
( 
	mahd NVARCHAR(50),
	mamh NVARCHAR(50),
	soluong TINYINT,

	primary key(mahd, mamh)
)

ALTER TABLE hoadon
ADD FOREIGN KEY (makh) REFERENCES khachhang(makh)

ALTER TABLE cthd
ADD FOREIGN KEY (mahd) REFERENCES hoadon(mahd)

ALTER TABLE cthd
ADD   FOREIGN KEY (mamh) REFERENCES mathang(mamh)

-- DẠNG 1:


--1.Cho biết danh sách gồm mã khách hàng, họ
-- tên, số điện thoại của khách hàng thành viên.

SELECT *
FROM khachhang
WHERE loaikh = 'TV';

--2.Cho biết danh sách gồm mã khách hàng, họ
--tên, số điện thoại của những khách hành VIP
--ở Long An và HCM

SELECT makh, tenkh, sdt
FROM khachhang
WHERE loaikh = 'VIP' AND (diachi = 'Long An' OR diachi = 'HCM');

--3.Cho biết số lượng hóa đơn xuất vào tháng 1

SELECT COUNT(distinct(mahd)) AS soluong
FROM hoadon
WHERE MONTH(ngaylap) = 1;

--4.Cho biết danh sách các mặt hàng có giá bán từ
--20 nghìn đến 50 nghìn

SELECT *
FROM mathang
WHERE gia >= 20000 AND gia <= 50000;

--5.Cho biết danh sách các hóa đơn có số lượng bán
--trên 50

SELECT *
FROM cthd
WHERE soluong > 50;

--6. Cho biết mã hóa đơn, mã mặt hàng, tên mặt
--hàng, giá, số lượng và tổng tiền mỗi mặt hàng
--của hóa đơn HD01

SELECT cthd.mahd, cthd.mamh, mathang.tenmh, mathang.gia, cthd.soluong, mathang.gia * cthd.soluong AS tongtien
FROM cthd
JOIN mathang ON cthd.mamh = mathang.mamh
WHERE cthd.mahd = 'HD01';

--7. Cho biết mã hóa đơn, mã mặt hàng, tên mặt
--hàng, giá, số lượng và tổng tiền mỗi mặt hàng
--của hóa đơn từ 300000 đến 500000

SELECT cthd.mahd, cthd.mamh, mathang.tenmh, mathang.gia, cthd.soluong, mathang.gia * cthd.soluong AS tongtien
FROM cthd
JOIN mathang ON cthd.mamh = mathang.mamh
WHERE mathang.gia * cthd.soluong >= 300000 AND mathang.gia * cthd.soluong <= 500000;

--8. Cho biết thông tin những khách hàng nào không
--mua hàng vào tháng 1.

SELECT khachhang.*
FROM khachhang
LEFT JOIN hoadon ON khachhang.makh = hoadon.makh AND MONTH(hoadon.ngaylap) = 1
WHERE hoadon.makh IS NULL;

--9. Cho biết mã hóa đơn, ngày lập hóa đơn, mã
--khách hàng và tổng tiền của những hóa đơn
--bán vào tháng 2

select ct.mahd, ngaylap, sum(gia * soluong) as 'Tổng Tiền'
from cthd as ct
join mathang as mh
on ct.mamh = mh.mamh
join hoadon as hd 
on hd.mahd = ct.mahd
where MONTH(ngaylap) = 2
group by ct.mahd, ngaylap;

--10. Cho biết danh sách các mặt hàng đã bán được.

SELECT mh.tenmh
FROM mathang mh
JOIN cthd ct ON mh.mamh = ct.mamh
JOIN hoadon hd ON ct.mahd = hd.mahd;





--DẠNG 2




--1. Đếm số hóa đơn của mỗi khách hàng
SELECT makh AS 'mã khách hàng' , COUNT(mahd) AS 'mã hoá đơn'
FROM hoadon
GROUP BY makh;																				

--2.Cho biết mã mặt hàng, tên mặt hàng, Tổng số
--lượng đã bán của từng mặt hàng
SELECT c.mamh, tenmh, SUM(soluong) AS 'số lượng'
FROM mathang AS mh
JOIN cthd AS c ON mh.mamh = c.mamh 
GROUP BY c.mamh,tenmh
	
--3. Cho biết mã hóa đơn, tổng thành tiền của những
--hóa đơn có tổng thành tiền lớn hơn 10 triệu.
SELECT mahd, SUM(gia*soluong) AS tong_tien
FROM mathang JOIN cthd ON mathang.mamh = cthd.mamh
GROUP BY mahd
HAVING SUM(gia*soluong)> 10000000

--4.Cho biết hóa đơn bán ít nhất hai mặt hàng
--MH01 và MH02.
SELECT mahd, COUNT(mamh) AS somathang
FROM cthd
WHERE mamh IN ('MH01','MH02')
GROUP BY mahd
HAVING COUNT(mamh)>=2

--5. Cho biết mã khách hàng, tên khách hàng, tổng
--thành tiền của từng hóa đơn
SELECT hoadon.mahd,khachhang.makh,tenkh, SUM(gia*soluong) AS tong_tien
FROM khachhang JOIN hoadon ON khachhang.makh = hoadon.makh
JOIN cthd ON hoadon.mahd = cthd.mahd JOIN mathang ON cthd.mamh = mathang.mamh
GROUP BY hoadon.mahd,khachhang.makh,tenkh

--6. Cho biết mã khách hàng, tên khách hàng, tổng
--thành tiền của khách hàng VIP.
SELECT khachhang.makh, khachhang.tenkh, SUM(cthd.soluong * mathang.gia) AS tongthanhtien
FROM khachhang
JOIN hoadon ON khachhang.makh = hoadon.makh
JOIN cthd ON hoadon.mahd = cthd.mahd
JOIN mathang ON cthd.mamh = mathang.mamh
WHERE khachhang.loaikh = 'VIP'
GROUP BY khachhang.makh, khachhang.tenkh;

--7. Cho biết mã khách hàng, tên khách hàng, tổng
--thành tiền của từng khách hàng có tổng thành
--tiền mua được >=10 triệu.
SELECT khachhang.makh, khachhang.tenkh, SUM(cthd.soluong * mathang.gia) AS tongthanhtien
FROM khachhang
JOIN hoadon ON khachhang.makh = hoadon.makh
JOIN cthd ON hoadon.mahd = cthd.mahd
JOIN mathang ON cthd.mamh = mathang.mamh
GROUP BY khachhang.makh, khachhang.tenkh
HAVING SUM(cthd.soluong * mathang.gia) >= 10000000;

--8. Cho biết thông tin khách hàng VIP có tổng
--thành tiền trong năm 2024 nhỏ hơn 10 triệu.
SELECT hoadon.mahd,khachhang.makh,tenkh, SUM(gia*soluong) AS tong_tien
FROM khachhang JOIN hoadon ON khachhang.makh = hoadon.makh
JOIN cthd ON hoadon.mahd = cthd.mahd JOIN mathang ON cthd.mamh = mathang.mamh 
WHERE loaikh = 'VIP'
GROUP BY hoadon.mahd,khachhang.makh,tenkh, hoadon.ngaylap
HAVING SUM(gia*soluong)<10000000 AND YEAR(ngaylap) = '2024'

--9. Cho biết hóa đơn có tổng trị giá lớn nhất gồm
--các thông tin: Mã hoá đơn, tổng trị giá của hóa
--đơn.
SELECT hoadon.mahd, SUM(cthd.soluong * mathang.gia) AS tongtrigia
FROM hoadon
JOIN cthd ON hoadon.mahd = cthd.mahd
JOIN mathang ON cthd.mamh = mathang.mamh
GROUP BY hoadon.mahd
ORDER BY tongtrigia DESC



--10. Cho biết hóa đơn có tổng trị giá lớn nhất trong
--tháng 2/2024 gồm các thông tin: Mã hóa đơn,
--ngày lập, tên khách hàng, số điện thoại khách
--hàng, tổng trị giá của hóa đơn.
SELECT hoadon.mahd, hoadon.ngaylap, khachhang.tenkh, khachhang.sdt, SUM(cthd.soluong * mathang.gia) AS tongtrigia
FROM hoadon
JOIN cthd ON hoadon.mahd = cthd.mahd
JOIN mathang ON cthd.mamh = mathang.mamh
JOIN khachhang ON hoadon.makh = khachhang.makh
WHERE hoadon.ngaylap >= '2024-02-01' AND hoadon.ngaylap <= '2024-02-29'
GROUP BY hoadon.mahd, hoadon.ngaylap, khachhang.tenkh, khachhang.sdt
ORDER BY tongtrigia DESC

--11. Cho biết hóa đơn có tổng trị giá nhỏ nhất gồm
--các thông tin: Mã hoá đơn, ngày lập, tên khách
--hàng, số điện thoại khách hàng, tổng trị giá của
--hóa đơn.
SELECT hoadon.mahd, hoadon.ngaylap, khachhang.tenkh, khachhang.sdt, SUM(cthd.soluong * mathang.gia) AS tongtrigia
FROM hoadon
JOIN cthd ON hoadon.mahd = cthd.mahd
JOIN mathang ON cthd.mamh = mathang.mamh
JOIN khachhang ON hoadon.makh = khachhang.makh
GROUP BY hoadon.mahd, hoadon.ngaylap, khachhang.tenkh, khachhang.sdt
ORDER BY tongtrigia ASC

--12. Cho biết thông tin của khách hàng có số lượng
--hóa đơn mua hàng nhiều nhất
SELECT khachhang.makh, khachhang.tenkh, khachhang.sdt, COUNT(hoadon.mahd) AS soluonghoadon
FROM khachhang
JOIN hoadon ON khachhang.makh = hoadon.makh
GROUP BY khachhang.makh, khachhang.tenkh, khachhang.sdt
ORDER BY soluonghoadon DESC


--13. Cho biết thông tin của khách hàng có số lượng
--hàng mua nhiều nhất.
SELECT khachhang.makh, khachhang.tenkh, khachhang.sdt, SUM(cthd.soluong) AS soluonghang
FROM khachhang
JOIN hoadon ON khachhang.makh = hoadon.makh
JOIN cthd ON hoadon.mahd = cthd.mahd
GROUP BY khachhang.makh, khachhang.tenkh, khachhang.sdt
ORDER BY soluonghang DESC



--14. Cho biết thông tin về các mặt hàng được bán
--trong nhiều hoá đơn nhất
SELECT mathang.mamh, mathang.tenmh, COUNT(DISTINCT hoadon.mahd) AS soluonghoadon
FROM mathang
JOIN cthd ON mathang.mamh = cthd.mamh
JOIN hoadon ON cthd.mahd = hoadon.mahd
GROUP BY mathang.mamh, mathang.tenmh
ORDER BY soluonghoadon DESC;


--15. Cho biết thông tin 3 mặt hàng được bán nhiều
--nhất.
SELECT mathang.mamh, mathang.tenmh, COUNT(cthd.mahd) AS soluongban
FROM mathang
JOIN cthd ON mathang.mamh = cthd.mamh
GROUP BY mathang.mamh, mathang.tenmh
ORDER BY soluongban DESC


--DẠNG 3


--1. Cho biết mã, tên mặt hàng chưa được bán.
SELECT mamh, tenmh
FROM mathang
WHERE mamh NOT IN (
    SELECT mamh
    FROM cthd
);

--2. Khách hàng nào không mua hàng vào tháng 1.
SELECT khachhang.makh, khachhang.tenkh
FROM khachhang
WHERE khachhang.makh NOT IN (
    SELECT hoadon.makh
    FROM hoadon 
    WHERE MONTH(hoadon.ngaylap) = 1
);

--3. Mặt hàng nào không bán được vào ngày 25/01/2024.
SELECT mathang.mamh, mathang.tenmh
FROM mathang
WHERE mathang.mamh NOT IN (
    SELECT cthd.mamh
    FROM cthd
    JOIN hoadon ON cthd.mahd = hoadon.mahd
    WHERE hoadon.ngaylap = '2024-01-25'
);

--4. Khách hàng nào có mua các mặt hàng sữa.

SELECT khachhang.makh, khachhang.tenkh
FROM khachhang
WHERE NOT EXISTS (
    SELECT *
    FROM mathang
    WHERE mathang.tenmh = 'sữa'
    AND NOT EXISTS (
        SELECT *
        FROM cthd
        JOIN hoadon ON cthd.mahd = hoadon.mahd
        WHERE hoadon.makh = khachhang.makh
        AND cthd.mamh = mathang.mamh
    )
);
--5. Tìm những đơn hàng do khách hàng VIP mua.
SELECT hoadon.mahd, hoadon.ngaylap, khachhang.makh, khachhang.tenkh, khachhang.loaikh
FROM hoadon
JOIN khachhang ON hoadon.makh = khachhang.makh
WHERE khachhang.loaikh IN (
    SELECT loaikh
    FROM khachhang
    WHERE loaikh = 'VIP'
)
GROUP BY hoadon.mahd, hoadon.ngaylap, khachhang.makh, khachhang.tenkh, khachhang.loaikh

