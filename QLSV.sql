CREATE DATABASE QLSV
GO 


USE QLSV

CREATE TABLE sinhvien
(
	masv SMALLINT PRIMARY KEY NOT NULL,
	hodem NVARCHAR(50) NOT NULL,
	ten NVARCHAR(50) NOT NULL,
	ngaysinh DATE NOT NULL,
	gioitinh BIT NOT NULL,
	noisinh NVARCHAR(50) NOT NULL,
	malop NVARCHAR(50) NOT NULL,
)

CREATE TABLE nganh
(
	manganh INT PRIMARY KEY NOT NULL,
	tennganh NVARCHAR(50) NOT NULL,
	makhoa NVARCHAR(50) NOT NULL,
)

CREATE TABLE lop
(
	malop NVARCHAR(50) PRIMARY KEY NOT NULL,
	tenlop NVARCHAR(50) NOT NULL,
	khoa TINYINT NOT NULL,
	nam SMALLINT NOT NULL,
	hedt NVARCHAR(50) NOT NULL,
	manganh INT NOT NULL,
	siso NVARCHAR(50) NOT NULL,
)
CREATE TABLE khoa
(
	makhoa NVARCHAR(50) PRIMARY KEY NOT NULL,
	tenkhoa NVARCHAR(50) NOT NULL,
	dienthoai INT NOT NULL,
)
CREATE TABLE ketqua
(
	masv SMALLINT NOT NULL,
	mahp TINYINT NOT NULL,
	diem FLOAT NOT NULL,
	PRIMARY KEY(masv,mahp),
)
CREATE TABLE hocphan
(
	mahp TINYINT PRIMARY KEY NOT NULL,
	tenhp NVARCHAR(50) NOT NULL,
	stc TINYINT NOT NULL,
	hocky TINYINT NOT NULL,
)

ALTER TABLE sinhvien
ADD CONSTRAINT FK_LOP_SINHVIEN
FOREIGN KEY (malop) REFERENCES lop(malop)

ALTER TABLE nganh
ADD CONSTRAINT FK_KHOA_NGANH 
FOREIGN KEY (makhoa) REFERENCES khoa(makhoa)

ALTER TABLE lop
ADD CONSTRAINT FK_LOP_NGANH 
FOREIGN KEY (manganh) REFERENCES nganh(manganh)

ALTER TABLE ketqua
ADD CONSTRAINT FK_KETQUA_SINHVIEN 
FOREIGN KEY (masv) REFERENCES sinhvien(masv)


ALTER TABLE ketqua
ADD CONSTRAINT FK_KETQUA_HOCPHAN 
FOREIGN KEY (mahp) REFERENCES hocphan(mahp)

--1. Hiển thị danh sách gồm: mã sinh viên, họ tên,
--mã lớp, ngày sinh (dd/mm/yyyy), năm sinh,
--giới tính (Nam, Nữ) của những sinh viên có họ
--không bắt đầu bằng chữ N,L,T
SELECT masv,hodem+ten AS ho_ten, malop, ngaysinh,
CASE gioitinh WHEN 1 THEN N'Nam' ELSE N'Nữ' END AS gioitinh
FROM sinhvien
WHERE ten NOT LIKE 'N%'
					 AND ten NOT LIKE 'L%'
					 AND ten NOT LIKE 'T%';

--2. Hiển thị danh sách gồm: mã sinh viên, họ tên,
--mã lớp, ngày sinh (dd/mm/yyyy), năm sinh,
--giới tính (Nam, Nữ) của những sinh viên nam
--học lớp PM23 và PM24.
SELECT* 
FROM sinhvien AS SV
WHERE gioitinh = 1 AND (SV.malop = 'PM23'
					 OR SV.malop = 'PM24');


--3. Hiển thị danh sách gồm: mã sinh viên, họ tên,
--mã lớp, ngày sinh (dd/mm/yyyy), giới tính (Nam,
--Nữ), tuổi của những sinh viên có tuổi từ 19 đến
--20 tuổi.
SELECT masv,hodem+ten AS ho_ten, malop, ngaysinh
FROM sinhvien
WHERE YEAR(GETDATE()) - YEAR(ngaysinh) BETWEEN 19 AND 20;

--4. Hiển thị danh sách mã sinh viên, họ tên, mã
--lớp, mã học phần, điểm được sắp xếp theo ưu
--tiên mã lớp, họ tên tăng dần
SELECT sv.masv, hodem+ten AS ho_ten, malop, mahp, diem
FROM sinhvien sv
JOIN ketqua kq ON sv.masv = kq.masv
ORDER BY sv.malop ASC, sv.hodem ASC, sv.ten ASC;

--5. Hiển thị danh sách gồm mã sinh viên, họ tên,
--mã lớp, mã học phần, điểm của những sinh viên
--có điểm học phần từ 5 đến 7 ở học kỳ I
SELECT sv.masv, sv.hodem, sv.ten, sv.malop, kq.mahp, kq.diem
FROM sinhvien sv
JOIN ketqua kq ON sv.masv = kq.masv
JOIN hocphan hp ON kq.mahp = hp.mahp
WHERE hp.hocky = 1 AND CAST(kq.diem AS FLOAT) BETWEEN 5 AND 7;


--DẠNG 2
--1. Cho biết mã lớp, tên lớp, tổng số sinh viên mỗi
--lớp.
SELECT SinhVien.malop, tenlop, COUNT(masv) AS siso
FROM Lop JOIN SinhVien ON Lop.malop=SinhVien.malop
GROUP BY SinhVien.malop, tenlop


--2. Cho biết mã lớp, tên lớp, số lượng sinh viên
--nam nữ theo từng lớp.
SELECT l.malop, l.tenlop, 
       COUNT(CASE WHEN s.gioitinh = 1 THEN 1 END) AS male_count,
       COUNT(CASE WHEN s.gioitinh = 0 THEN 1 END) AS female_count
FROM lop l
JOIN sinhvien s ON l.malop = s.malop
GROUP BY l.malop, l.tenlop;

--3. Cho biết điểm trung bình của sinh viên. Biết
--rằng DTB = tổng điểm học phần * số tín chỉ
--chia tổng số tín chỉ.
 SELECT masv, SUM(diem*stc)/SUM(stc) AS DTB
FROM HocPhan JOIN KetQua
ON HocPhan.mahp = KetQua.mahp
GROUP BY masv

--4. Cho biết DTB của sinh viên ở học kỳ 1.
SELECT masv, SUM(diem*stc)/SUM(stc) AS DTB
FROM HocPhan JOIN KetQua ON HocPhan.mahp=KetQua.mahp
WHERE HocKy = '1'
GROUP BY masv

--5. Cho biết mã sinh viên, họ tên, số các học phần
--điểm dưới 8 của mỗi sinh viên.
SELECT s.masv, hodem+ten AS hoten, COUNT(kq.masv) AS sohocphan_duoi_8
FROM sinhvien s
LEFT JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.diem < 8 OR kq.diem IS NULL
GROUP BY s.masv, s.hodem, s.ten;

--6. Đếm số sinh viên có điểm dưới 8 của mỗi học
--phần.
SELECT hp.mahp, hp.tenhp, COUNT(kq.masv) AS sosinhvien_duoi_8
FROM hocphan hp
LEFT JOIN ketqua kq ON hp.mahp = kq.mahp
WHERE kq.diem < 8 OR kq.diem IS NULL
GROUP BY hp.mahp, hp.tenhp;

--7. Tính tổng số tín chỉ có điểm dưới 8 của mỗi
--sinh viên.
SELECT s.masv, hodem+ten AS hoten, SUM(hp.stc) AS tong_tinchi_duoi_8
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
JOIN hocphan hp ON kq.mahp = hp.mahp
WHERE kq.diem < 8
GROUP BY s.masv, s.hodem, s.ten;

--8. Cho biết mã lớp, tên lớp có tổng số sinh viên
--trên 10.
SELECT l.malop, l.tenlop
FROM lop l
JOIN sinhvien s ON l.malop = s.malop
GROUP BY l.malop, l.tenlop
HAVING COUNT(s.masv) > 10;

--9. Cho biết sinh viên nào có số học phần điểm
--trên 8 nhiều nhất.
SELECT s.masv, hodem+ten AS hoten, COUNT(kq.masv) AS sohocphan_tren_8
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.diem > 8
GROUP BY s.masv, s.hodem, s.ten
ORDER BY sohocphan_tren_8 DESC

--10. Cho biết sinh viên nào có DTB các học phần
--trên 8.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
GROUP BY s.masv, s.hodem, s.ten
HAVING AVG(kq.diem) > 8;

--11. Sinh viên có trên 2 học phần có điểm trên 8.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
GROUP BY s.masv, s.hodem, s.ten
HAVING COUNT(CASE WHEN kq.diem > 8 THEN 1 END) > 2;

--12. Sinh viên học ít nhất 2 học phần mã ’010’, ’011’.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
JOIN hocphan hp ON kq.mahp = hp.mahp
WHERE hp.mahp IN ('010', '011')
GROUP BY s.masv, s.hodem, s.ten
HAVING COUNT(DISTINCT hp.mahp) >= 2;

--13. Sinh viên có điểm TBC cao nhất ở học kỳ 1.
SELECT s.masv, hodem+ten AS hoten, AVG(kq.diem) AS tbchientai
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
JOIN hocphan hp ON kq.mahp = hp.mahp
WHERE hp.hocky = 1
GROUP BY s.masv, s.hodem, s.ten
ORDER BY tbchientai DESC

--14. Sinh viên có tổng số điểm các học phần thấp
--nhất.
SELECT s.masv, hodem+ten AS hoten, SUM(kq.diem) AS tongdiem
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
GROUP BY s.masv, s.hodem, s.ten
ORDER BY tongdiem ASC

--15. Cho biết các học phần có số sinh viên điểm trên
--8 nhiều nhất.
SELECT hp.mahp, hp.tenhp, COUNT(kq.masv) AS soluong
FROM hocphan hp
JOIN ketqua kq ON hp.mahp = kq.mahp
WHERE kq.diem > 8
GROUP BY hp.mahp, hp.tenhp
ORDER BY soluong DESC;



----DẠNG 3

--1. Tìm sinh viên không học học phần nào.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
WHERE s.masv NOT IN (SELECT DISTINCT kq.masv FROM ketqua kq);

--2. Tìm sinh viên chưa học học phần có mã ’020’.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
WHERE s.masv NOT IN (SELECT DISTINCT kq.masv FROM ketqua kq JOIN hocphan hp ON kq.mahp = hp.mahp WHERE hp.mahp = '020');

--3. Học phần không có sinh viên nào có điểm >8.
SELECT hp.mahp, hp.tenhp
FROM hocphan hp
WHERE hp.mahp NOT IN (SELECT DISTINCT kq.mahp FROM ketqua kq WHERE kq.diem > 8);

--4. Tìm sinh viên không có học phần nào điểm <8.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
WHERE s.masv NOT IN (SELECT DISTINCT kq.masv FROM ketqua kq WHERE kq.diem < 8);

--5. Cho biết học phần nào không có sinh viên học.
SELECT hp.mahp, hp.tenhp
FROM hocphan hp
WHERE hp.mahp NOT IN (SELECT DISTINCT kq.mahp FROM ketqua kq);

--6. Cho biết tên lớp có sinh viên tên Long.
SELECT DISTINCT l.tenlop
FROM lop l
JOIN sinhvien s ON l.malop = s.malop
WHERE s.ten = 'Long';

--7. Tìm sinh viên có điểm học phần ’010’ là <8.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.mahp = '010' AND kq.diem < 8;

--8. Tìm sinh viên có học học phần Toán cao cấp.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
JOIN hocphan hp ON kq.mahp = hp.mahp
WHERE hp.tenhp = 'Toán cao cấp';

--9. Tìm sinh viên bằng điểm học phần ’011’ với
--sinh viên có mã là 2401.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.mahp = '011' AND s.masv = '2401';

--10. Cho biết danh sách các học phần có số tín chỉ
--lớn hơn hoặc bằng số tín chỉ của học phần ’001’
SELECT mahp, tenhp
FROM hocphan
WHERE hocphan.stc >= (SELECT hocphan.stc FROM hocphan WHERE mahp = '001');


----DẠNG 4

--1. Cho biết sinh viên có điểm cao nhất.
SELECT s.masv, hodem+ten AS hoten, MAX(kq.diem) AS diemcao
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
GROUP BY s.masv, s.hodem, s.ten
HAVING MAX(kq.diem) = (SELECT MAX(diem) FROM ketqua);

--2. Cho biết sinh viên có tuổi lớn nhất.
SELECT masv, hodem+ten AS hoten, MAX(ngaysinh) AS tuoilonnhat
FROM sinhvien
GROUP BY masv, hodem, ten
HAVING MAX(ngaysinh) = (SELECT MAX(ngaysinh) FROM sinhvien);

--3. Sinh viên có điểm học phần ’001’ cao nhất.
SELECT s.masv, hodem+ten AS hoten, kq.diem
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.mahp = '001'
ORDER BY kq.diem DESC

--4. Khoa nào có số lượng sinh viên nhiều nhất.
SELECT tenkhoa , COUNT(*) AS soluong
FROM khoa
GROUP BY tenkhoa
ORDER BY soluong DESC

--5. Cho biết mã sinh viên, mã học phần có điểm lớn
--hơn bất kỳ các điểm của sinh viên mã ’2401’.
SELECT kq.masv, kq.mahp, kq.diem
FROM ketqua kq
WHERE kq.diem > ANY (SELECT kq2.diem FROM ketqua kq2 WHERE kq2.masv = '2401');

--6. Cho biết sinh viên có điểm học phần nào đó lớn
--hơn gấp rưỡi điểm trung bình của sinh viên đó.
SELECT s.masv, hodem+ten AS hoten, kq.mahp, kq.diem
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.diem > (SELECT AVG(kq2.diem) * 1.5 FROM ketqua kq2 WHERE kq2.masv = s.masv);

--7. Cho biết lớp nào không có sinh viên học.
SELECT tenlop
FROM lop
WHERE tenlop NOT IN (SELECT tenlop FROM sinhvien);

--8. Cho biết sinh viên nào chưa học học phần nào.
SELECT masv, hodem+ten AS hoten
FROM sinhvien
WHERE masv NOT IN (SELECT DISTINCT masv FROM ketqua);

--9. Sinh viên nào học cả hai học phần ’001’ và ’002’.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq1 ON s.masv = kq1.masv AND kq1.mahp = '001'
JOIN ketqua kq2 ON s.masv = kq2.masv AND kq2.mahp = '002';

--10. Sinh viên nào học một trong hai học phần trên.
SELECT s.masv, hodem+ten AS hoten
FROM sinhvien s
JOIN ketqua kq ON s.masv = kq.masv
WHERE kq.mahp = '001' OR kq.mahp = '002';


--DẠNG 5
--1. Bổ sung một dòng dữ liệu cho bảng Khoa bộ
--giá trị sau: (’KT’, ’Kế toán’,’0961669078’).

INSERT INTO khoa (makhoa,tenkhoa,dienthoai)
VALUES (N'HKT', N'Kế toán','0961669078')

--2. Thêm một sinh viên bất kỳ vào bảng SinhVien.
insert into sinhvien(masv,hodem,ten,ngaysinh,gioitinh,noisinh,malop)
values('1702',N'Trần Hoài',N'Khang','2002-02-16',1,N'Nam Định',N'HQ24')

--3. Thêm điểm học phần bất kỳ vào bảng KetQua.
INSERT INTO ketqua(masv, mahp, diem)
VALUES ('123', '001', 8.5);

--4. Xóa các sinh viên có DTB < 3 (buộc thôi học).
DELETE FROM sinhvien
WHERE masv IN (
    SELECT masv
    FROM (
        SELECT masv, AVG(diem) AS DTB
        FROM ketqua
        GROUP BY masv
    ) AS dtb_sinhvien
    WHERE DTB < 3
)


--5. Xóa các sinh viên không học học phần nào.
DELETE FROM SinhVien WHERE masv
NOT IN (SELECT DISTINCT masv FROM KetQua)


--6. Xóa khỏi bảng Lop những lớp không có sinh
--viên nào.
DELETE FROM lop
WHERE malop NOT IN (
    SELECT DISTINCT malop
    FROM sinhvien
)

--7. Thêm cột XepLoai vào bảng SinhVien, cập
--nhật dữ liệu cột XepLoai theo yêu cầu sau:
--• Nếu DTB >=8 thì xếp loại Giỏi
--• Nếu DTB >=7 thì xếp loại Khá
--• Nếu DTB >=5 thì xếp loại Trung bình
--• Ngược lại là Yếu
ALTER TABLE sinhvien
ADD XepLoai NVARCHAR(50);

UPDATE SinhVien
SET XepLoai = 
    CASE 
        WHEN (SELECT AVG(diem) FROM ketqua WHERE ketqua.masv = SinhVien.masv) >= 8 THEN 'Giỏi'
        WHEN (SELECT AVG(diem) FROM ketqua WHERE ketqua.masv = SinhVien.masv) >= 7 THEN 'Khá'
        WHEN (SELECT AVG(diem) FROM ketqua WHERE ketqua.masv = SinhVien.masv) >= 5 THEN 'Trung bình'
        ELSE 'Yếu'
    END;


--8. Thêm cột XetLenLop vào bảng SinhVien, cập
--nhật dữ liệu cột XetLenLop theo yêu cầu sau:
--• Nếu DTB >=5 thì được lên lớp, ngược lại
--• Nếu DTB >=3 tạm ngừng tiến độ học tập
--• Ngược lại buộc thôi học

ALTER TABLE SinhVien
ADD XetLenLop NVARCHAR(50);

UPDATE SinhVien
SET XetLenLop = 
    CASE 
        WHEN (SELECT AVG(diem) FROM ketqua WHERE ketqua.masv = SinhVien.masv) >= 5 THEN N'Được lên lớp'
        WHEN (SELECT AVG(diem) FROM ketqua WHERE ketqua.masv = SinhVien.masv) >= 3 THEN N'Tạm ngừng tiến độ học tập'
        ELSE N'Buộc thôi học'
    END;
