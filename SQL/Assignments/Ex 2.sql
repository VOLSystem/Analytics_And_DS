--1
CREATE TABLE license_history (
license_id varchar(12) NOT NULL,
staff_id varchar(12) NOT NULL,
license_no varchar(12) NOT NULL,
license_type varchar(10),
date_awarded DATE CHECK(date_awarded <= GETDATE()),
expiration_date DATE CHECK(expiration_date >= GETDATE()),
CONSTRAINT license_history_PK PRIMARY KEY (license_id, staff_id),
CONSTRAINT license_history_FK FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
ON UPDATE CASCADE ON DELETE SET NULL) ;

--2
SELECT STAFF.staff_id,staff_last_name, staff_first_name, spec_title, count(pre_number)NumOfPrescriptionsWritten
FROM STAFF INNER JOIN staff_medspec
ON STAFF.staff_id = staff_medspec.staff_id
INNER JOIN medical_specialty
ON staff_medspec.specialty_code = medical_specialty.specialty_code
INNER JOIN
prescription
ON STAFF.staff_id = prescription.staff_id
GROUP BY STAFF.staff_id, staff_last_name, staff_first_name, spec_title, date_hired, staff_medspec.specialty_code
HAVING date_hired NOT BETWEEN '1-JAN-1985' AND '31-DEC-2005'
AND staff_medspec.specialty_code NOT IN ('RN1')
--4 staff members

--3
select med_name_common, count(medicine.medicine_code)TimesIssuedWithoutDirections
from medicine inner join prescription
on medicine.medicine_code = prescription.medicine_code
group by med_name_common, prescription.medicine_code, dosage_directions
having dosage_directions IS NULL
--5 medications

--4
select service_cat_desc
from service_cat left join service
on service_cat.service_cat_id = service.service_cat_id
where service_id is null
--Gynecology, Office Department Service Excaminations


--5 
SELECT staff_last_name, date_hired, pre_date
FROM staff INNER JOIN prescription
ON staff.staff_id = prescription.staff_id
GROUP BY staff_last_name, staff.staff_id, date_hired, pre_date
HAVING (pre_date - date_hired) < 90
--1 employee

--6
SELECT treatment_date, pat_id, staff.staff_id
FROM treatment inner join staff
ON treatment.staff_id = staff.staff_id
GROUP BY treatment_date, pat_id, staff.staff_id, treatment_comments
HAVING treatment_comments LIKE '%blood%'
--15 treatments

--7
SELECT service_cat_desc, count(service_id)#OfAssociatedServices
FROM service_cat left join service
ON service_cat.service_cat_id = service.service_cat_id
GROUP BY service_cat_desc
HAVING service_cat_desc IN ('Cardiology','Radiology','Gynecology','Surgery')
--4 rows

--8
select count(treatment_number)#OfTreatments
from treatment
group by pat_id

select AVG(#OfTreatments)
from (select count(treatment_number)#OfTreatments
		from treatment
		group by pat_id)AvgTreatments

SELECT patient.pat_id, pat_last_name, count(treatment_number)#OfTreatmentsReceived
FROM treatment INNER JOIN patient
ON treatment.pat_id = patient.pat_id
GROUP BY patient.pat_id, pat_last_name
HAVING count(treatment_number) > (2*(select AVG(#OfTreatments)
										from (select count(treatment_number)#OfTreatments
										from treatment
										group by pat_id)AvgTreatments))
ORDER BY count(treatment_number) DESC
--2 patients

--9
SELECT ward_dept_name, COUNT(treatment_number)#OfTreatmentsProvided
FROM treatment INNER JOIN staff
ON treatment.staff_id = staff.staff_id
INNER JOIN ward_dept
ON staff.ward_dept_assigned = ward_dept.ward_id
GROUP BY ward_dept_name, staff_last_name
HAVING COUNT(treatment_number) > 10
AND staff_last_name NOT IN ('Zumwalt')

--10
SELECT staff_id, staff_last_name, salary, count(pre_number)

select *
from medical_specialty

SELECT staff.staff_id, salary AS AnnualPay
FROM staff inner join staff_medspec
ON staff.staff_id = staff_medspec.staff_id
INNER JOIN medical_specialty
ON staff_medspec.specialty_code = medical_specialty.specialty_code
group by spec_title, staff.staff_id, salary
HAVING spec_title NOT IN ('Licensed Practicing Nurse', 'Nurse-Practitioner','Radiology Technologist',
'Registered Nurse')

SELECT count(pre_number)#OfPrescriptions
FROM prescription inner join staff
ON prescription.staff_id = staff.staff_id
GROUP BY staff.staff_id

SELECT AVG(#OfPrescriptions)
FROM (SELECT count(pre_number)#OfPrescriptions
	FROM prescription inner join staff
	ON prescription.staff_id = staff.staff_id
	GROUP BY staff.staff_id)AvgPrescrip