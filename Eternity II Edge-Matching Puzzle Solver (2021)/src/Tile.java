
public class Tile 
{

	private int ID;
	private int[] directions = new int[4]; // north, east, south, west
	private int degree = 0;
	
	public Tile(int newID, int[] directionNumbers)
	{
		for (int i = 0; i < 4; i++)
			directions[i] = directionNumbers[i];
		
		ID = newID;
	}
	
	public void rotate(int degree)				// 1, 2, or 3. Number of ROR-style ops
	{
		int[] temp = new int[4];
		
		for (int i = 0; i < 4; i++)
			temp[(i+degree)%4] = this.directions[i];
		
		for (int i = 0; i < 4; i++)
			this.directions[i] = temp[i];
		
		this.logDegree(degree);
		
	}
	
	public int[] getDirections()					// returns current orientation, int array
	{	return directions;		}
	
	
	public String returnTile()							// returns current orientation, string		
	{
		String s = "";
		
		for (int i = 0; i < 4; i++)
			s = s + this.directions[i] + " ";
		
		s = s + "  ID: " + this.getID() + "  Deg: " + this.getDegree();
		
		return s;
	}
	
	public void reportTile()							// reports current orientation, for debugging		
	{
		String s = this.returnTile();		
		System.out.println(s);
	}
	
	public void logDegree(int rotDeg)
	{	degree = (degree + rotDeg) % 4;	}
	
	public int getDegree()
	{ return this.degree;	}
	
	public int getID()
	{ return ID;	}
	
}
