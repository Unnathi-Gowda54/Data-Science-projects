USE imdb;

-- To begin with, it is beneficial to know the shape of the tables and whether any column has null values.

select count(*) from director_mapping;
select count(*) from genre;
select count(*) from movie;
select count(*) from names;
select count(*) from ratings;
select count(*) from role_mapping;


select count(*) as id_nulls from movie where id is null;
select count(*) as title_nulls from movie where title is null;
select count(*) as year_nulls from movie where year is null;
select count(*) as date_published_nulls from movie where date_published is null;
select count(*) as duration_nulls from movie where duration is null;
select count(*) as country_nulls from movie where country is null;
select count(*) as worlwide_gross_income_nulls from movie where worlwide_gross_income is null;
select count(*) as languages_nulls from movie where languages is null;
select count(*) as production_company_nulls from movie where production_company is null;

-- Four columns of the movie table has null values. 

-- the total number of movies released each year
select year as Year,     
count(*) as number_of_movies 
from movie 
group by Year 
order by Year;

-- the trend month wise
select month(date_published) as month_num,
count(*) as number_of_movies 
from movie 
group by month_num 
order by month_num;

/*The highest number of movies is produced in the month of March.
So, now that we have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- How many movies were produced in the USA or India in the year 2019??
select count(*) as no_of_movies_in_USA_India 
from movie
where 
country = ("USA" or "India")
and 
year = 2019;

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.

Let’s find out the different genres in the dataset.*/

select distinct genre from genre;

-- Which genre had the highest number of movies produced overall?

select genre as genre , 
count(*) as number_of_movies 
from genre 
group by genre 
order by number_of_movies desc limit 1;

/* So, based on the insight, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- How many movies belong to only one genre?

select count(*) as number_of_movies_belonging_to_only_one_genre
from 
(
select movie_id 
from genre 
group by movie_id 
having count(*)=1
) 
as single_genre_movie;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- What is the average duration of movies in each genre? 

select 
	genre as genre, 
	avg(duration) as avg_duration 
from genre 
inner join 
	movie on genre.movie_id = movie.id 
group by genre;

/* Movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- The rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced is,

select genre as genre, 
	count(id) as movie_count, 
	rank() over (order by count(id) desc) as genre_rank
from genre
inner join 
	movie on genre.movie_id = movie.id
group by genre
order by movie_count desc;


--Thriller movies is in top 3 among all genres in terms of number of movies

-- The minimum and maximum values in  each column of the ratings table except the movie_id column, 

select min(avg_rating) as min_avg_rating , 
	max(avg_rating) as max_avg_rating,
	min(total_votes) as min_total_votes , 
	max(total_votes) as max_total_votes,
	min(median_rating) as min_median_rating , 
	max(median_rating) as max_median_rating 
from ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

select title , 
	avg(avg_rating) as avg_rating , 
	rank() over (order by avg(avg_rating) desc) as movie_rank
from movie 
inner join 
	ratings on movie.id = ratings.movie_id 
group by title
order by avg_rating desc 
limit 10;






/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

select median_rating, 
	count(median_rating) as movie_count
from ratings 
group by median_rating
order by median_rating asc;





/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

select production_company, 
	count(*) as movie_count,
	rank() over (order by count(*) desc) as prod_company_rank
from movie 
inner join
	ratings on movie.id = ratings.movie_id
group by production_company
having avg(avg_rating) > 8
order by movie_count desc;






-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select genre, 
	count(id) as  movie_count
from genre
inner join 
	movie on genre.movie_id = movie.id 
inner join 
	ratings on movie.id = ratings.movie_id
where year(date_published) = 2017 and 
	monthname(date_published) = "March"
group by genre
having avg(total_votes) > 1000 
order by movie_count desc;




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

select title, 
	round(avg(avg_rating),1) as avg_rating, genre 
from movie 
inner join  
	ratings on movie.id = ratings.movie_id
inner join  
	genre on ratings.movie_id = genre.movie_id
where title like "The%" 
group by title, genre
having avg(avg_rating) > 8 
order by avg_rating desc;




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

select count(*) as no_of_movies_with_median_rating_grater_than_8 
from movie
inner join 
	ratings on movie.id = ratings.movie_id
where date_published between "2018-04-01" and "2019-04-01"
and median_rating > 8;






-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

select country, sum(total_votes) as total_number_of_votes
from movie 
inner join 
	ratings on movie.id = ratings.movie_id
where country in ("Germany","Italy")
group by country 
order by total_number_of_votes desc;




-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select count(*) as name_nulls from names where name is null;
select count(*) as height_nulls from names where height is null;
select count(*) as date_of_birth_nulls from names where date_of_birth is null;
select count(*) as known_for_movies_nulls from names where known_for_movies is null;



/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select director_name, count(*) as movie_count
from 
(
	select name as director_name, avg(avg_rating) as avg_rating
	from names 
    inner join 
		ratings on names.known_for_movies = ratings.movie_id
	inner join 
		genre on ratings.movie_id = genre.movie_id
	group by director_name, genre
	having avg(avg_rating) > 8
) 
as top_movie_genres
group by director_name
order by movie_count desc
limit 3;


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select name as actor_name, count(*) as movie_count
from names 
	inner join 
		role_mapping on names.id = role_mapping.name_id
	inner join 
		movie on role_mapping.movie_id = movie.id 
	inner join 
		ratings on movie.id = ratings.movie_id
where median_rating>=8 and category = 'actor'
group by actor_name 
order by movie_count desc
limit 2;



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select * from 
( 
	select production_company, 
		sum(total_votes) as vote_count,
		rank() over (order by sum(total_votes) desc) as prod_comp_rank
	from movie 
	inner join
		ratings on	movie.id = ratings.movie_id
	where production_company is not null
	group by production_company
) 
as production_company_rank_details_on_votes 
where prod_comp_rank <=3;







/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

select *, 
	rank() over(order by actor_avg_rating desc, total_votes desc) as actor_rank
from
(
	select name as actor_name, 
		sum(total_votes) as total_votes,
		count(movie.id) as movie_count,
		round(sum(avg_rating*total_votes)/sum(total_votes),2) as actor_avg_rating
	from names 
    inner join 
		role_mapping on	names.id = role_mapping.name_id
	inner join 
		movie on role_mapping.movie_id = movie.id
	inner join ratings on
		movie.id = ratings.movie_id
	where category = 'actor' and upper(country) like '%INDIA%'
	group by actor_name
) 
as actor_ratings_based_on_votes
where movie_count>=5;






-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

select *, 
	rank() over(order by actress_avg_rating desc, total_votes desc) as actress_rank
from
(
	select name as actress_name, sum(total_votes) as total_votes,
	count(movie.id) as movie_count,
	round(sum(avg_rating*total_votes)/sum(total_votes),2) as actress_avg_rating
	from names 
	inner join 
		role_mapping on names.id = role_mapping.name_id
	inner join movie on
		role_mapping.movie_id = movie.id
	inner join ratings on
		movie.id = ratings.movie_id
	where category = 'actress' and upper(languages) like '%HINDI%'
	group by actress_name
) as actress_ratings_based_on_votes
where movie_count>=3;







/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

select title as name_of_movie,
case 
	when avg_rating > 8 then 'Superhit'
	when avg_rating between 7 and 8 then 'Hit'
	when avg_rating between 5 and 7 then 'One time watch'
else 'Flop'
end as movie_ratings
from movie 
inner join 
	ratings on movie.id = ratings.movie_id
inner join genre on 
	ratings.movie_id = genre.movie_id
where Upper(genre) = 'THRILLER'
and total_votes > 25000;



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select genre, round(avg(duration), 2) as avg_duration,
round(sum(avg(duration)) over (order by genre), 2) as running_total_duration,
round(avg(avg(duration)) over (order by genre), 2) as moving_avg_duration
from genre
inner join movie 
on genre.movie_id = movie.id
group by genre
order by genre;
	






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies




select genre, year, movie_name,
worlwide_gross_income, movie_rank
from
(
select genre.genre, year, title as movie_name,
worlwide_gross_income,
rank() over (partition by genre, year order by worlwide_gross_income desc) as movie_rank
from movie inner join genre  
on movie.id = genre.movie_id
inner join  
   (
   select grmc.genre
    from
	   (
        select genre.genre, count(movie.id) as movie_count,
        rank() over (order by count(movie.id) desc) as genre_rank
        from genre
        inner join movie on genre.movie_id = movie.id
        group by genre
        ) as grmc
    where genre_rank <= 3
    ) as genre_rank_movie_count
    on genre.genre = genre_rank_movie_count.genre
) as highest_grossing_movies
where movie_rank <= 5;






-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select * from 
(
	select production_company, count(movie.id) as movie_count,
	rank() over (order by count(movie.id) desc) as prod_comp_rank
	from movie 
    inner join 
		ratings on movie.id = ratings.movie_id
	where median_rating >=8 and production_company is not null 
    and position(',' in languages)>0
	group by production_company 
) as production_houses
where prod_comp_rank <= 2;






-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

select *, 
rank() over(order by actress_avg_rating desc, total_votes desc)
as actress_rank
from
(
	select name as actress_name, sum(total_votes) as total_votes,
		count(movie.id) as movie_count,
		round(sum(avg_rating*total_votes)/sum(total_votes),2) as actress_avg_rating
	from names 
    inner join 
		role_mapping on names.id = role_mapping.name_id
	inner join 
		movie on role_mapping.movie_id = movie.id
	inner join 
		ratings on movie.id = ratings.movie_id
	inner join 
		genre on ratings.movie_id = genre.movie_id
	where category = 'actress' 
    and avg_rating>8 
    and genre = "Drama"
	group by actress_name
) 
as actress_ratings_based_on_votes_drama_genre;






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

select
    director_mapping.name_id as director_id,
    names.name as director_name,
    count(distinct movie.id) as number_of_movies,
    avg(datediff(movie.date_published, min_date_published)) as avg_inter_movie_days,
    avg(ratings.avg_rating) as avg_rating,
    sum(ratings.total_votes) as total_votes,
    min(ratings.min_rating) as min_rating,
    max(ratings.max_rating) as max_rating,
    sum(movie.duration) as total_duration
from names
inner join
    director_mapping on names.id = director_mapping.name_id
inner join
    movie on director_mapping.movie_id = movie.id
left join
    (
        select
            movie_id,
            avg(avg_rating) as avg_rating,
            sum(total_votes) as total_votes,
            min(avg_rating) as min_rating,
            max(avg_rating) as max_rating
        from
            ratings
        group by
            movie_id
    ) ratings on movie.id = ratings.movie_id
cross join
    (select min(date_published) as min_date_published from movie) as min_date
group by
    director_mapping.name_id, names.name
order by
    number_of_movies desc
limit 9;













