-- comp9311 22T2 Project 1

-- Q1:
create or replace view Q1(subject_code)
as
--... SQL statements, possibly using other views/functions defined by you ...
select s.code as subject_code
from subjects as s, orgunits as o
where s.offeredby=o.id
and s.career='PG'
and s.uoc>12
and o.longname='School of Computer Science and Engineering';

-- Q2:
create or replace view Q2(course_id)
as
--... SQL statements, possibly using other views/functions defined by you ...
select courses.id as course_id
from courses, classes, semesters
where courses.id=classes.course
and courses.semester=semesters.id
and semesters.year=2002
and semesters.term='S1'
group by courses.id
having count(distinct classes.ctype)>=3;

-- Q3:
create or replace view Q3(unsw_id, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select temp1.unswid,temp1.name
from

(select p.unswid,p.name,sem.year,sem.term
from people as p,
	 students as stu, 
	 semesters as sem, 
	 subjects as sub,
	 courses as c,
	 course_enrolments as ce
where stu.id=p.id
and stu.id=ce.student
and ce.course=c.id
and c.subject=sub.id
and sem.id=c.semester
and stu.stype='local'
and sub.code='COMP9311') as temp1,

(select p.unswid,p.name,sem.year,sem.term
from people as p,
	 students as stu, 
	 semesters as sem, 
	 subjects as sub,
	 courses as c,
	 course_enrolments as ce
where stu.id=p.id
and stu.id=ce.student
and ce.course=c.id
and c.subject=sub.id
and sem.id=c.semester
and stu.stype='local'
and sub.code='COMP9331') as temp2

where temp1.year=temp2.year
and temp1.term=temp2.term
and temp1.unswid=temp2.unswid;

-- Q4:
create or replace view Q4(term, max_fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
select sem.name ,temp3.fail_rate as max_fail_rate
from
(
select temp2.id,temp2.year,temp2.term,(temp2.num_of_fail/temp1.num_of_all)::numeric(5,4) as fail_rate
from 
	(select sem.id,sem.year, sem.term,count(ce.mark)::float as num_of_all
	from semesters as sem,
		 course_enrolments as ce,
		 courses as c,
		 subjects as sub
	where c.subject=sub.id
	and c.id=ce.course
	and sem.id=c.semester
	and sem.year in ('2009','2010','2011','2012')
	and sub.code='COMP9311'
	and ce.mark IS NOT NULL
	group by (sem.id,sem.year,sem.term)) as temp1,

	(select sem.id,sem.year, sem.term,count(ce.mark)::float as num_of_fail
	from semesters as sem,
		 course_enrolments as ce,
		 courses as c,
		 subjects as sub
	where c.subject=sub.id
	and c.id=ce.course
	and sem.id=c.semester
	and sem.year in ('2009','2010','2011','2012')
	and sub.code='COMP9311'
	and ce.mark IS NOT NULL
	and ce.mark<50
	group by (sem.id,sem.year,sem.term)) as temp2

where temp2.id=temp1.id
) as temp3,
semesters as sem
where sem.id=temp3.id

order by temp3.fail_rate desc
limit 1;

-- Q5:
create or replace view Q5(unsw_id, student_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select p.unswid,p.name
from people as p,
(select distinct(p.unswid)
from people as p,
	 students as stu, 
	 courses as c,
	 course_enrolments as ce
where stu.id=p.id
and stu.id=ce.student
and ce.course=c.id
and stu.stype='intl'
and p.unswid not in
(select distinct(p.unswid)
from people as p,
	 students as stu, 
	 courses as c,
	 course_enrolments as ce
where stu.id=p.id
and stu.id=ce.student
and ce.course=c.id
and stu.stype='intl'
and ce.grade!='HD'
)) as temp1
where p.unswid=temp1.unswid;

-- Q6:
create or replace view Q6(school_name, stream_count)
as
--... SQL statements, possibly using other views/functions defined by you ...
select temp1.longname as school_name,temp1.stream_count
from
	(select o.id,o.longname,count(distinct s.id) as stream_count
	from orgunits as o,
		 orgunit_types as ot,
		 streams as s
	where s.offeredby=o.id
	and o.utype=ot.id
	and ot.name='School'
	group by o.id) as temp1,

	(select o.id,o.longname,count(distinct s.id) as stream_count
	from orgunits as o,
		 orgunit_types as ot,
		 streams as s
	where s.offeredby=o.id
	and o.utype=ot.id
	and ot.name='School'
	and o.longname='School of Chemical Engineering'
	group by o.id) as temp2

where temp1.stream_count>temp2.stream_count;

-- Q7:
create or replace view Q7(course_id, staff_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select c.id,p.name
from courses as c,
	 subjects as sub,
	 orgunits as o,
	 semesters as sem,
	 
	 classes as cl,
	 buildings as b,
	 rooms as r,

	 people as p,
	 course_staff as cs,
	 staff
where c.subject=sub.id
and sub.offeredby=o.id
and c.semester=sem.id
and c.id=cs.course

and staff.id=cs.staff
and p.id=staff.id
and p.name is not NULL

and cl.room=r.id
and r.building=b.id
and cl.course=c.id

and sem.year='2010'
and sem.term='S2'
and o.longname='School of Computer Science and Engineering'
group by (c.id,p.name)
having count(distinct b.id)>3;

-- Q8:
create or replace view Q8(unsw_id, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select p.unswid,p.name
from people as p,

	(select distinct(p.id)
	from people as p,
		 students as stu,
		 program_enrolments as pe,
		 programs as prog,
		 program_degrees as pd
	where p.id=stu.id
	and stu.id=pe.student
	and pe.program=prog.id
	and prog.id=pd.program
	and pd.abbrev='MSc') as temp1,

	(select p.id
	from people as p,
		 students as stu,	 
		 course_enrolments as ce,
		 courses as c,
		 semesters as sem	 
	where p.id=stu.id
	and stu.id=ce.student
	and c.semester=sem.id
	and c.id=ce.course
	and ce.mark>=50
	and sem.year='2012'
	and sem.term='S2') as temp2,

	(select p.id
	from people as p,
		 students as stu,
		 courses as c,
		 course_enrolments as ce,
		 semesters as sem
	where p.id=stu.id
	and stu.id=ce.student
	and ce.course=c.id
	and c.semester=sem.id
	and sem.year<2013
	and ce.mark>=50
	group by p.id
	having avg(ce.mark)>=80) as temp3,

	(select p.id,prog.id as prog_id
	from people as p,
		 students as stu,
		 semesters as sem,
		 courses as c,
		 course_enrolments as ce,
		 subjects as sub,
		 programs as prog,
		 program_enrolments as pe
	where p.id=stu.id
	and stu.id=ce.student
	and ce.course=c.id
	and c.subject=sub.id
	and c.semester=sem.id
	and stu.id=pe.student
	and pe.program=prog.id
	and pe.semester=sem.id
	and sem.year<2013
	and ce.mark>=50
	group by (p.id,prog.id)
	having sum(sub.uoc)>=prog.uoc) as temp4
where p.id=temp1.id
and p.id=temp2.id
and p.id=temp3.id
and p.id=temp4.id
group by p.id;

-- Q9:
create or replace view Q9(unsw_id, name, academic_standing)
as
--... SQL statements, possibly using other views/functions defined by you ...
select p.unswid,p.name, 
case when temp3.fail_rate=1 and num_of_all=1 then 'Referral'
	 when temp3.fail_rate is NULL and num_of_all=1 then 'Good'
	 when temp3.fail_rate is NULL and num_of_all>1 then 'Good'
	 when temp3.fail_rate=1 and num_of_all>1 then 'Probation'
	 when temp3.fail_rate>=0.5 and temp3.fail_rate<=1 and num_of_all>1 then 'Referral'
	 when temp3.fail_rate<0.5 and num_of_all>1 then 'Good' END

from people as p,

(select temp1.id,(temp2.num_of_fail/temp1.num_of_all) as fail_rate, temp1.num_of_all
from
	(select p.id,count(ce.mark)::float as num_of_all
	from people as p,
		 students as stu,
		 courses as c,
		 course_enrolments as ce,
		 subjects as sub,
		 semesters as sem

	where p.id=stu.id
	and stu.id=ce.student
	and ce.course=c.id
	and c.subject=sub.id
	and c.semester=sem.id

	and p.unswid::text LIKE '313%'
	and sem.year = '2012'
	and sem.term = 'S1'
	and ce.mark is not NULL
	and ce.mark>=0
	group by p.id) as temp1 left join

	(select p.id,count(ce.mark)::float as num_of_fail
	from people as p,
		 students as stu,
		 courses as c,
		 course_enrolments as ce,
		 subjects as sub,
		 semesters as sem

	where p.id=stu.id
	and stu.id=ce.student
	and ce.course=c.id
	and c.subject=sub.id
	and c.semester=sem.id

	and p.unswid::text LIKE '313%'
	and sem.year = '2012'
	and sem.term = 'S1'
	and ce.mark is not NULL
	and ce.mark>=0
	and ce.mark<50
	group by p.id) as temp2
on temp1.id = temp2.id) as temp3
where p.id=temp3.id;

-- Q10
create or replace function 
	Q10(staff_id integer) returns setof text
as $$
--... SQL statements, possibly using other views/functions defined by you ...


begin

	return query select *  from
	(select o.longname || '/' || sr.name || '/' || aff.starting  
	from orgunits as o,
		 affiliations as aff,
		 staff_roles as sr,
		 staff as s
		 
	where o.id=aff.orgunit
	and aff.role=sr.id
	and aff.staff=s.id
	and s.id=staff_id
	order by (aff.starting,sr.name,o.longname)) as temp;

end;


$$ language plpgsql;

-- Q11
create or replace function 
	Q11(year courseyeartype, term character(2), orgunit_id integer) returns setof text
as $$
--... SQL statements, possibly using other views/functions defined by you ...


begin

return query select* from
(
select temp1.code || ' ' || 
case when (temp2.pass_num/temp1.all_num)::numeric(5,4) is null then 0.0000
	 when (temp2.pass_num/temp1.all_num)::numeric(5,4)>0 then (temp2.pass_num/temp1.all_num)::numeric(5,4) end

from
(select sub.code,ce.course,count(stu.id)::float as all_num
from students as stu,
	 courses as c,
	 course_enrolments as ce,
	 subjects as sub,
	 semesters as sem,
	 orgunits as o
where stu.id=ce.student
and ce.course=c.id
and c.subject=sub.id
and c.semester=sem.id
and sub.offeredby=o.id
and o.id=orgunit_id
and sem.year=$1
and sem.term=$2
group by (sub.code,ce.course)) as temp1 left join

(select sub.code,ce.course,count(stu.id)::float as pass_num
from students as stu,
	 courses as c,
	 course_enrolments as ce,
	 subjects as sub,
	 semesters as sem,
	 orgunits as o
where stu.id=ce.student
and ce.course=c.id
and c.subject=sub.id
and c.semester=sem.id
and sub.offeredby=o.id
and o.id=orgunit_id
and sem.year=$1
and sem.term=$2
and ce.grade in ('SY', 'PC', 'PS', 'CR', 'DN', 'HD')
group by (sub.code,ce.course)) as temp2 

on temp1.code=temp2.code
and temp1.course=temp2.course
and temp1.all_num!=0) as temp3;

end;



$$ language plpgsql;

-- Q12
create or replace function 
	Q12(code character(8)) returns setof text
as $$
--... SQL statements, possibly using other views/functions defined by you ...

begin

return query 
select * from
(
select sub.code::text
from subjects as sub
where sub._prereq like concat('%',$1,'%')
and substring(sub.code,1,4)=substring($1,1,4)) as temp;

end;



$$ language plpgsql;
