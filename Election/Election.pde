import de.bezier.data.*;

XlsReader reader;

ArrayList<Candidate> candidates = new ArrayList<Candidate>();

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
    
    String candidateID = reader.getString();
    
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
    
    if(percentage > 0.01) candidates.add(new Candidate(name, party, candidateID));
    }
    
    println(candidates.size());
  }
  
  