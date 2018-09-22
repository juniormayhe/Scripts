//get time difference in months between dates
function diffMonths(dt2, dt1) 
{
  var diff =(dt2.getTime() - dt1.getTime()) / 1000;
  diff /= (60 * 60 * 24 * 7 * 4);
  return Math.abs(Math.round(diff));
}

dt1 = new Date(2018,10,1);
dt2 = new Date(2018,12,31);
console.log(diff_months(dt1, dt2));
