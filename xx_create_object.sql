WHENEVER SQLERROR CONTINUE;

-- Create Employee table xx_employee

DROP TABLE xx_employee;

CREATE TABLE xx_employee
(
  employee_id    NUMBER PRIMARY KEY,
  employee_name  VARCHAR2(50) NOT NULL,
  job_title      VARCHAR2(50) NOT NULL,
  manager_id     NUMBER,
  date_hired     DATE NOT NULL,
  salary         NUMBER NOT NULL,
  department_id  NUMBER NOT NULL  
 );


-- Create Department table xx_department

DROP TABLE xx_department;

CREATE TABLE xx_department
(
  department_id    NUMBER PRIMARY KEY,
  department_name  VARCHAR2(50) NOT NULL,
  location         VARCHAR2(50) NOT NULL
);

-- Create directory to place data file

CREATE OR REPLACE DIRECTORY file_load AS 'C:\oracle\data';

--Create External table for employee data load

DROP TABLE xx_employee_stg;

CREATE TABLE xx_employee_stg(
  employee_id    NUMBER NOT NULL,
  employee_name  VARCHAR2(50) NOT NULL,
  job_title      VARCHAR2(50) NOT NULL,
  manager_id     NUMBER,
  date_hired     DATE NOT NULL,
  salary         NUMBER NOT NULL,
  department_id  NUMBER NOT NULL 
)
ORGANIZATION EXTERNAL(
    TYPE oracle_loader
    DEFAULT DIRECTORY file_load
    ACCESS PARAMETERS 
    (RECORDS DELIMITED BY NEWLINE
     SKIP 1
     FIELDS TERMINATED BY ','
     MISSING FIELD VALUES ARE NULL
     (employee_id,   
      employee_name,
      job_title,
      manager_id,
      date_hired   date 'dd/mm/yy',
      salary,
      department_id
      )  )        
    LOCATION ('employee.csv')
);

-- Create External table for department data load

DROP TABLE xx_department_stg;

CREATE TABLE xx_department_stg(
  department_id    NUMBER NOT NULL,
  department_name  VARCHAR2(50) NOT NULL,
  location         VARCHAR2(50) NOT NULL
)
ORGANIZATION EXTERNAL(
    TYPE oracle_loader
    DEFAULT DIRECTORY file_load
    ACCESS PARAMETERS 
    (RECORDS DELIMITED BY NEWLINE
     SKIP 1
     FIELDS TERMINATED BY ',')
    LOCATION ('department.csv')
);


--#===========================================================================================
   --    Component Name: xx_create_emp
   --    Description: Procedure to create a new employee in DB
--#===========================================================================================

   CREATE OR REPLACE PROCEDURE xx_create_emp(
      p_employee_id                   IN              NUMBER
    , p_employee_name                 IN              VARCHAR2
    , p_job_title                     IN              VARCHAR2
    , p_manager_id                    IN              NUMBER
    , p_date_hired                    IN              DATE
    , p_salary                        IN              NUMBER
    , p_department_id                 IN              VARCHAR2
     )
   IS

   BEGIN

      DBMS_OUTPUT.PUT_LINE('Details are being inserted to table');

      INSERT INTO xx_employee VALUES( p_employee_id, p_employee_name, p_job_title
                                    , p_manager_id,  p_date_hired,  p_salary,  p_department_id);                                                                                                                            
        IF SQL%ROWCOUNT=1 THEN      
     
           DBMS_OUTPUT.PUT_LINE('Employee record successfully inserted to table...');

           COMMIT;

           ELSE

           DBMS_OUTPUT.PUT_LINE('Employee record not inserted correctly. Please investigate...');

           ROLLBACK;

        END IF;
   

   EXCEPTION

   WHEN OTHERS THEN

   DBMS_OUTPUT.PUT_LINE('Error while inserting employee record'||SQLCODE||':'||SQLERRM);

   ROLLBACK;
   
   END;

/

SHOW ERR;
  --#===========================================================================================
   --    Component Name: xx_update_salary
   --    Description: Procedure to increase or decrease salary of an emp
   --    Negative value for percentage to be passed to decrease salary
  --#===========================================================================================

   CREATE OR REPLACE PROCEDURE xx_update_salary(
      p_employee_id                   IN              NUMBER
    , p_percentage                    IN              NUMBER
     )
   IS

   BEGIN

      DBMS_OUTPUT.PUT_LINE('Details are being updated to table');

         UPDATE xx_employee 
            SET salary = salary + (salary * p_percentage/100) 
         WHERE  employee_id = p_employee_id;

        IF SQL%ROWCOUNT=1 THEN      
     
           DBMS_OUTPUT.PUT_LINE('Employee salary successfully updated in table...');

           COMMIT;

           ELSE

           DBMS_OUTPUT.PUT_LINE('Employee salary not updated. Please investigate if the correct employee_id was provided...');

           ROLLBACK;

        END IF;

   EXCEPTION

      WHEN OTHERS THEN

         DBMS_OUTPUT.PUT_LINE('Error while updating salary'||SQLCODE||':'||SQLERRM);
   
   END;

/

SHOW ERR;
  --#===========================================================================================
   --    Component Name: xx_update_department
   --    Description: Procedure to transfer employee to a different department
  --#===========================================================================================

   CREATE OR REPLACE PROCEDURE xx_update_department(
      p_employee_id                   IN              NUMBER
    , p_new_dep_id                    IN              NUMBER
     )
   IS

    l_dept_count NUMBER:=0;

   BEGIN

      -- to check the given department_id is valid

      SELECT count(*) 
        INTO l_dept_count
        FROM xx_department
      WHERE department_id = p_new_dep_id;

     IF l_dept_count =1 THEN

      DBMS_OUTPUT.PUT_LINE('New department is valid');

         UPDATE xx_employee 
            SET department_id = p_new_dep_id 
         WHERE  employee_id = p_employee_id;

        IF SQL%ROWCOUNT=1 THEN      
     
           DBMS_OUTPUT.PUT_LINE('Employee department successfully updated...');

           COMMIT;

        ELSE

           DBMS_OUTPUT.PUT_LINE('Employee department not updated correctly. Please investigate the given employee_id is correct...');

           ROLLBACK;

        END IF;

      ELSE
       DBMS_OUTPUT.PUT_LINE('New department is invalid');
     END IF;

   EXCEPTION

      WHEN OTHERS THEN

         DBMS_OUTPUT.PUT_LINE('Error while updating department'||SQLCODE||':'||SQLERRM);
         
         ROLLBACK;
   
   END;

/


SHOW ERR;
  --#===========================================================================================
   --    Component Name: xx_return_salary
   --    Description: function to return the salary of an employee
  --#===========================================================================================

   CREATE OR REPLACE FUNCTION xx_return_salary(
           p_employee_id   IN   NUMBER
       ) RETURN NUMBER

   IS

      v_salary NUMBER:=0;
  
   BEGIN

      SELECT NVL(salary,0) 
       INTO  v_salary
      FROM xx_employee
      WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Salary is'||v_salary);

     RETURN v_salary;
       
  EXCEPTION

     WHEN NO_DATA_FOUND THEN
     
         DBMS_OUTPUT.PUT_LINE('Employee record not found for the given employee_id');
         RETURN NULL;

      WHEN OTHERS THEN

         DBMS_OUTPUT.PUT_LINE('Error while fetching salary'||SQLCODE||':'||SQLERRM);
         RETURN NULL;
   
   END;

/

SHOW ERR;




