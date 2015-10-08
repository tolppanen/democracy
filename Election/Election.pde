import de.bezier.data.*;

XlsReader reader;

void setup() {
  size(600,400);
  
  reader = new XlsReader( this, "data/formatted_data_2012.xls");
  reader.firstRow();
  
  while (reader.hasMoreRows() ) {
    reader.nextRow();
    reader.firstCell();
    reader.nextCell();
    
    String state = reader.getString();
    
    reader.nextCell();
    
    
    String district = reader.getString();
    
    reader.nextCell();
    
    //String candidateID = reader.getString();
    
    reader.nextCell();
    
    String name = reader.getString();
    reader.nextCell();
    
    String party = reader.getString();
    
    reader.nextCell();
    
    Integer votes = reader.getInt();

    
    reader.nextCell();
    
    Float percentage = reader.getFloat();
    
    reader.nextCell();
    
    String winner = reader.getString();
    
    String resultString;
    
    if(winner.equals("W") && votes.equals(0)) resultString = " unopposed.";
    else resultString = " with " + votes + " votes." + "(" + percentage * 100 + "%)";
    
    if(winner.equals("W")){
    println("Candidate " + name + "(" + party + ")" + " won district " + district + " of " + state + resultString);
    }
    
    
  }
  
  
}