
String parseDateTime(DateTime time){
  if(time == null) return null;
  return '${time.month}/${time.day}/${time.year % 2000}';
}