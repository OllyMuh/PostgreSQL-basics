/*
1. What operations do the following functions perform: film_in_stock, film_not_in_stock, inventory_in_stock, get_customer_balance,
inventory_held_by_customer, rewards_report, last_day?

film_in_stock - inventory_ids of current film, which are in the current stock

film_not_in_stock -  inventory_ids of current film, which are not in the current stock

inventory_in_stock returns true or false as the result of presense current inventory_id in the stock

get_customer_balance returns all the unpaid fees by the payments of the currrent customer on the current moment of time

inventory_held_by_customer returns customer_id of the customer, which has taken and not return current inventory of the film

last_day returns last day(date) of the month which is used as agrument - timestamp*/


/*
 * 2. Why does ‘rewards_report’ function return 0 rows? Correct and recreate the function, so that it's able to return rows properly.
 * 
 * I have no answer yet. Didn't like the current_date in this function because of different period of time - it may be reflect on the result
 * but it still dosn't work. 
 */

/*
 * 3. Is there any function that can potentially be removed from the dvd_rental codebase? If so, which one and why?
 * I'd like to remove the film_not_in_stock function because it doesn't have sence to look for films that are definitely not there. 
