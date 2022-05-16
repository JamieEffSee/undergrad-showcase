import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.Queue;
import java.util.LinkedList;
import java.util.Random;
import java.math.*;

public class GameBoard 
{

	private int area;
	private int size;
	private int piecesPlaced;
	private double fastestSolve;
	private Tile[][] board, bestBoard;
	public String[] solutions;
	private int solnsIdx;
	private Queue<Tile> cornerBag = new LinkedList<>();
	private Queue<Tile> borderBag = new LinkedList<>();
	private Queue<Tile> centerBag = new LinkedList<>();
	private boolean[] timeWarning = {false, false, false};
	private int[] bestSolve = {0,0};		// iteration ID; # of pieces placed in that iteration
	private double solveTime = 0.0;			// solve time of ^ this ^ best solve
	
	// Constructor
	public GameBoard(int boardSize)
	{
		size = boardSize;
		area = size * size;
		board = new Tile[size][size];
		piecesPlaced = 0;
		solutions = new String[((size/2) + 6)/2];
		solutions[0] = "";
		solnsIdx = 0;
		fastestSolve = 0;
		createTileBags();
		
		//Shuffling bags
		shuffleBag(cornerBag);
		shuffleBag(borderBag);
		shuffleBag(centerBag);
	}
	
	// Getters
	public int getArea()
	{	return area;	}
	
	public int getSize()
	{	return size;	}
	
	public Tile[][] getBoard()
	{	return board;	}
	
	public int getPiecesPlaced()
	{	return piecesPlaced;	}
	
	public Tile getBoardElement(int row, int col)
	{	return board[row][col];	}
	
	
	public void placeTile(Tile tile, int row, int col)
	{
		board[row][col] = tile;
		piecesPlaced++;
	}
	
	// Helper method to constructor
	// populates bags with Tiles
	public void createTileBags()
	{
		// Build tileFile string and load file
		String tileFile = "./codes/tilesets/";		// NOTE: hardcoded tileset folder!
		
		if (size >=2 & size <= 15)
			tileFile = tileFile + size + "x" + size + ".txt";
		else if (size == 16)
			tileFile = tileFile + "E2_Tiles.txt";
		else
			tileFile = tileFile + "badInput.txt";
		
		try
		{
			Scanner tileFileScanner = new Scanner(new File(tileFile));
			
			int w = size - 2;
			populateBag(4, 0, cornerBag, tileFileScanner);
			populateBag(4 * w, 4, borderBag, tileFileScanner);
			populateBag(w * w, 4 + (4*w), centerBag, tileFileScanner);
		}
  		
  		catch (FileNotFoundException e)
		{	e.printStackTrace();	}
	}
	
	// Helper helper
	public static void populateBag(int numberOfTiles, int startIDx, Queue<Tile> activeBag, Scanner sc)
	{
		for (int i = 1; i <=numberOfTiles; i++)
		{
			String[] nextLineInFile = sc.nextLine().split(" ");
			int[] newDirs = new int[4];
			for (int j = 0; j < nextLineInFile.length; j++)
				newDirs[j] = Integer.parseInt(nextLineInFile[j]);
			
			int newID = startIDx + i;
			Tile nextTile = new Tile(newID, newDirs);
			activeBag.add(nextTile);
		}
	}
	
	// Modified Knuth shuffle for a tile bag
	// possibly broken but perfectly serviceable for this application
	public static void shuffleBag(Queue<Tile> bag)	
	{
		int size = bag.size();
		
		for (int i = 1; i < size; i ++)
		{
			Random r = new Random();
			int q = r.nextInt(i) + 1;
			
			Tile heldTile = bag.poll();
			for (int j = 0; j < q; j ++)
				bag.add(bag.poll());
			bag.add(heldTile);
		}
	}
	
	
	public void solve(int numberOfIterations, int detail, int depth, int bktk)
	{
		// Parameter definitions
		int solveIteration;
  		int solveVolume = numberOfIterations * 5 + 0;	// "fine gain" on iterations; see driver
  		int solveDepth = 1 + depth;
  		
  		// Solution tracking - works with bestSolve and solveTime
  		int successfulSolves = 0;
  	
  		
  		// Stopwatches
  		// iterTime tracks the length of one iteration
  		// killSolve stops the entire solve (infinite loop handling)
  		// boolean values confirm to the user that the program isn't looping infinitely
  		Stopwatch iterTime;
  		Stopwatch killSolve = new Stopwatch();
  		
  		// Main solve loop: each loop is one iterated solve attempt on an empty board
  		System.out.println("Solve in progress...");
  		ITER: for (solveIteration = 1; solveIteration <= solveVolume; solveIteration++)
  		{
  			
  			// This controls the depth of the multiple backtracking protocol.
  			// Set these values carefully!!!
  			int[] removeTokens = {3, 3, 2, 2, 2, 2, 1, 1, 1, 1};
  			// Seriously, especially the last few
  			
  			// Time elapsed for this iteration
  			iterTime = new Stopwatch();
  			
  			// Progress bar
  			if(detail > 0 && detail < 3)
  			{
	  			if (size < 7 && solveIteration%1000 == 0)
	  				System.out.println("Iteration progress: " + solveIteration + 
	  				" out of " + solveVolume);
	  			
	  			else if (size >=7 && size < 9 && solveIteration%500 == 0)
	  				System.out.println("Iteration progress: " + solveIteration + 
	  				" out of " + solveVolume);
	  			
	  			else if (size >= 9 && size < 12 && solveIteration%100 == 0)
	  				System.out.println("Iteration progress: " + solveIteration + 
	  				" out of " + solveVolume);
	  			
	  			else if (size >= 12 && solveIteration%10 == 0)
	  				System.out.println("Iteration progress: " + solveIteration + 
	  				" out of " + solveVolume);
	  			
  			}
  			
  			else if (detail == 3)
  				System.out.println("Iteration " + solveIteration);
  			// end Progress bar
  			
	  		
  			// Place First Row of puzzle by brute force
  			// 
	  		boolean firstRowFlagAssert = false;
	  		while (!firstRowFlagAssert)
	  		{
	  			// kill check - might be overkill in first row
	  			// but one can't be too careful
	  			// no checkForBestSolve() - if it's first row I'm not interested
	  			if (killSwitch(killSolve, solveDepth, ""))
	  				break ITER;
	  			
	  			firstRowFlagAssert = this.placeFirstRow();
	  			
	  			if (!firstRowFlagAssert)
	  				this.removeRow(0);
//	  			else
//	  				System.out.println("First row complete");
	  		}
	  		//
	  		// End First Row
	  		
	  		
	  		
	  		// Fill the next (n-2) rows
	  		//
	  		
	  		CENTER: for (int centerRowIdx = 1; centerRowIdx <= size-2; centerRowIdx++)	
	  		{
		  		
	  			//System.out.println("Poll before row " + (i+1) + ": ");
		  		//pollBags(1, 1, 1);
	  			
	  			// attempt to place a valid row
	  			//String s = "cr" + Integer.toString(centerRowIdx) + " ";
	  			String s = "";
	  			boolean centerRowFlagAssert = false;
		  		int attempts = 0;
		  		
		  		// define iteration attempt limits for this row
  				int attemptLimit = size*centerBag.size();
  				if (size > 8)
  					attemptLimit = attemptLimit - (3*centerBag.size()) + (25*size);
  				
		  		
		  		// The while loop is a "trap" that is escaped by placing a valid row
		  		while (!centerRowFlagAssert)
		  		{
		  			++attempts;
		  			
		  			// If a row isn't getting filled, shuffle a stale bag
		  			if ((attempts*attempts) > centerBag.size())
		  				shuffleBag(centerBag);
		  			
		  			// Try and place a center row
		  			centerRowFlagAssert = this.placeCenterRow(centerRowIdx);
		  			
		  			if (!centerRowFlagAssert)  // row placement unsuccessful
		  			{
		  				checkForBestSolve(solveIteration, iterTime);
		  				// iteration attempt limit exceeded
		  				// start new iteration
		  				if (attempts > attemptLimit)
		  				{
		  					//System.out.println("Jammed up!");
		  					this.clearBoard();
		  					continue ITER;
		  				}
		  				
		  				// Time limit exceeded; end solving routine
			  			
			  			if (killSwitch(killSolve, solveDepth, s))
			  				break ITER;
		  				
		  				// Backtracking protocol
			  			//
			  			// the nested if statements are the last addition to the program
			  			// and are meant to offer more flexibility with the backtracking.
			  			// They certainly can increase time per iteration, especially for large n.
			  			// They do improve best solution time for smaller n but do not affect quality,
			  			// and do in fact seem to lower quality ever so slightly for larger n.
			  			
			  			// multiple row backtracking
			  			if(bktk > 0)
			  			{
			  				if (centerRowIdx >= 4 && attempts > 100)
			  					if(removeTokens[0] > 0)
			  					{
			  						//System.out.print("0 ");
			  						removeMultipleRows(centerRowIdx, 3);
			  						centerRowIdx = centerRowIdx - 3;
			  						--removeTokens[0];
			  						continue CENTER;
			  						
			  					}
			  			
			  				if (centerRowIdx >= 4 && attempts > 40)
			  					if(removeTokens[1] > 0)
			  					{
			  						//System.out.print("1 ");
			  						removeMultipleRows(centerRowIdx, 2);
			  						centerRowIdx = centerRowIdx - 2;
			  						--removeTokens[1];
			  						continue CENTER;
			  					}
			  			
			  				if (centerRowIdx >= 5 && attempts > 100)
			  					if(removeTokens[2] > 0)
			  					{
			  						//System.out.print("2 ");
			  						removeMultipleRows(centerRowIdx, 3);
			  						centerRowIdx = centerRowIdx - 3;
			  						--removeTokens[2];
			  						if (bktk == 2)
			  						{
			  							++removeTokens[1];
			  							++removeTokens[0];
			  						}
			  					
			  						continue CENTER;
			  					}
			  			
			  				if (centerRowIdx >= 5 && attempts > 40)
			  					if(removeTokens[3] > 0)
			  					{
			  						//System.out.print("3 ");
			  						removeMultipleRows(centerRowIdx, 2);
			  						centerRowIdx = centerRowIdx - 2;
			  						--removeTokens[3];
			  						continue CENTER;
			  						
			  					}
			  			
			  				if (centerRowIdx >= 6 && attempts > 100)
			  					if(removeTokens[4] > 0)
			  					{
			  						//System.out.print("4 ");
			  						removeMultipleRows(centerRowIdx, 3);
			  						centerRowIdx = centerRowIdx - 3;
			  						--removeTokens[4];
			  						if (bktk == 2)
			  						{
			  							++removeTokens[3];
			  							++removeTokens[1];
			  							++removeTokens[0];
			  						}
			  						continue CENTER;
			  						
			  					}
			  			
			  				if (centerRowIdx >= 7 && attempts > 100)
			  					if(removeTokens[5] > 0)
			  					{
			  						//System.out.print("5 ");
			  						removeMultipleRows(centerRowIdx, 3);
			  						centerRowIdx = centerRowIdx - 3;
			  						--removeTokens[5];
			  						if (bktk == 2)
			  						{
			  							++removeTokens[4];
			  							++removeTokens[3];
			  							++removeTokens[2];
			  						}
			  						continue CENTER;
			  					}
			  			
			  				if (centerRowIdx >= 8 && attempts > 100)
			  					if(removeTokens[6] > 0)
			  					{
			  						//System.out.print("6 ");
			  						removeMultipleRows(centerRowIdx, 3);
			  						centerRowIdx = centerRowIdx - 3;
			  						--removeTokens[6];
			  						if (bktk == 2)
			  							++removeTokens[5];
			  							
			  						continue CENTER;
			  					}
			  			
			  				if (centerRowIdx >= 9 && attempts > 100)
			  					if(removeTokens[7] > 0)
			  					{
			  						//System.out.print("7 ");
			  						removeMultipleRows(centerRowIdx, 3);
			  						centerRowIdx = centerRowIdx - 3;
			  						--removeTokens[7];
			  						if (bktk == 2)
			  							++removeTokens[6];
			  						continue CENTER;
			  					}
			  		
			  				if (centerRowIdx >= 9 && attempts > 200)
			  					if(removeTokens[8] > 0)
			  					{
			  						//System.out.print("8 ");
			  						removeMultipleRows(centerRowIdx, 4);
			  						centerRowIdx = centerRowIdx - 4;
			  						--removeTokens[8];
			  						if (bktk == 2)
			  							++removeTokens[7];
		  							continue CENTER;
			  					}
			  			
				  			if (centerRowIdx >= 9 && attempts > 300)
			  					if(removeTokens[9] > 0)
			  					{
			  						//System.out.print("9 ");
			  						removeMultipleRows(centerRowIdx, 5);
			  						centerRowIdx = centerRowIdx - 5;
			  						--removeTokens[9];
			  						if (bktk == 2)
			  							++removeTokens[8];
			  						continue CENTER;
			  					}
			  			}		// end multiple row backtracking
			  			
			  			// vanilla backtracking
		  				this.removeRow(centerRowIdx);
		  			
		  				
		  			}	 // end if (row placement unsuccessful)
		  			
		  		}		 // end while (trap to place a valid row)
	  		
	  		} 			 // end for done filling center rows
	  		
	  		
	  		// Place Last Row of puzzle by sheer hope
	  		
  			String s = "";
  			boolean lastRowFlagAssert = false;
	  		int attemptsLR = 0;
	  		int attemptsLimitLR;
	  		if (size == 2)
	  			attemptsLimitLR = 3;
	  		else
	  			attemptsLimitLR = 3*size*borderBag.size();
	  		
	  		while (lastRowFlagAssert == false)
	  		{
	  			attemptsLR++;
	  			
	  			// If we just can't jam the last row home, clear the board
	  			// and try again.
	  			// Potential here for improved backtracking but I'd have to pass
	  			// control back to the center loop somehow
	  			// Speaking to this: we have at this point removed the entire last row 
	  			if (attemptsLR > attemptsLimitLR)
				{
					//System.out.println("Jammed up! Too many attemptsLR.");
					checkForBestSolve(solveIteration, iterTime);
					this.clearBoard();
					continue ITER;
				}
	  			
	  			
	  			// Shuffle sooner, since it's last row
	  			if (attemptsLR > size*borderBag.size())
	  				shuffleBag(borderBag);
	  			
	  			
	  			lastRowFlagAssert = this.placeLastRow();
	  			
	  			//Successful solve
	  			if (lastRowFlagAssert == true)
	  			{
	  				
	  				if(detail>0)
	  					System.out.println("Solution found (iteration " + solveIteration + ")");
	  				
	  				successfulSolves++;
	  				bestSolve[0] = solveIteration;
					bestSolve[1] = this.getPiecesPlaced();
					solveTime = iterTime.elapsedTime("m");
					
					// Create a string containing this solution
					String soln = "";
					for (int k = 0; k < size; k++)
					{
						soln = soln + "Row " + (k+1) + "\n";
						for (int j = 0; j < size; j++)
						{
							soln = soln + this.getBoardElement(k, j).returnTile() +"\n";
							//Row finished, new line
							if (j != 0 && ((j+1) % size == 0))
								soln = soln + "\n";
						}
					}
					
					// Deal with successful solves: break if depth = 0
					// and examine redundant solves if not
					if (successfulSolves == 1)
					{
						solutions[0] = soln;
						solnsIdx++;
						fastestSolve = killSolve.elapsedTime("m");
						if(depth == 0)
						{
							++solveIteration;
							break ITER;
						}
					}
						
					
					// eliminate redundant solutions (broken)
					else
					{
						if(solnsIdx < ((size/2) + 6)/2)
						{
							for (int i = 0; i < solnsIdx; i++)
							{	
								if(solutions[i] == soln)
									break;
								
								if(i+1 == solnsIdx)
									solutions[solnsIdx++] = soln;	
							}
						}
					}
					
					
	  			}	// end successful solve
	  			
	  			else	// unsuccessful solve
	  			{	
	  				checkForBestSolve(solveIteration, iterTime);
	  				
	  				if (killSwitch(killSolve, solveDepth, s))
		  				break ITER;
	  				
	  				// Remove last row
	  				this.removeRow(size - 1);
	  			}	
	  			
	  		}	// end place last row
	  		
			// Clear board and start again
	  		this.clearBoard();
	  		
  		} // end ITER loop (all iterations are done, or time has run out)
  		
  		
  		// Display data summary
  		double endTime = killSolve.elapsedTime("m");
  		System.out.println("Solve complete.");
  		System.out.println("Size " + size + ": " + successfulSolves + 
  							" successful solve(s) out of " + (solveIteration-1));
  		System.out.println("Best solve: Iteration " + bestSolve[0] + 
  						" (" + bestSolve[1] + " out of " + area + " pieces placed)");
  		
  		double quality = 100*(double)(bestSolve[1])/(double)(area);
  		long qual = Math.round(quality);
  		System.out.println("Solution quality = " + qual + "%");
  		
  		// Display solutions
  		
  		// No solutions to display
  		if (solnsIdx == 0)
  		{
  			// If solveTime <1ms and isn't captured, give it a reasonable solveTime
  	  		if(solveTime == 0.0)
  	  			solveTime = 1.05;
  	  		solveTime =  solveTime * (double)bestSolve[0];
  	  		long sT = Math.round(solveTime);
  			System.out.println("No full solution found\n(best solve took at least " + sT + " ms)");
  			
  		}	
  			
  		else
  		{	
  			System.out.println(solnsIdx + " solve(s) captured - earliest solve took " + fastestSolve + " ms");
  			
  			if(detail >= 2)
  			{
  				for(int i = 0; i < solnsIdx; i++)
  					System.out.println("Solution " + (i+1) + ": \nN E S W\n" + solutions[i]);	
  			}
  			
  			else
  			System.out.println("One solution (row by row): \nN E S W\n" + solutions[0]);
  		}
	}	// end solve()
	
	
	//
	//
	// assessXXXXXXTile(Tile, row and/or column)
	// The following four methods check the state of a candidate tile against its target destination
	// The board receives a Tile, and assesses whether it can fit (in any orientation)
	// at [targetRow, targetCol]. If so, the Tile is rotated so that it fits the space
	// in a valid orientation, and returns true.
	// If the piece will not fit any which way, returns false.
	
	// Usually the method will check if any of the activeTile's colors match even one of the colors
	// of existing neighbour tiles. If not, we know we can discard the tile right away.
	// if there is a potential match, the tile is further checked depending on whether or not
	// the border is involved.
	
	public boolean assessCenterTile(Tile activeTile, int targetRow, int targetCol)
	{

		int i = 0;
		while (i < 4)
		{
			//System.out.println("Assessing center ID " + activeTile.getID() + " " + i);
			// check north board tile
			if (activeTile.getDirections()[i] == board[targetRow-1][targetCol].getDirections()[2])
			{
				// check west board tile
				if (activeTile.getDirections()[(i+3)%4] == board[targetRow][targetCol-1].getDirections()[1])
				{
					// a match has been found. apply native rotate based on i and flag up
					if (i%2 == 0)
						activeTile.rotate(i);
					else	// i = 1 or 3
						activeTile.rotate((i+2)%4);
					return true;
				}
			}
			i++;
		}	// end while
		
		return false;	// tile is discarded
		
	}	// end assessCenterTile()
	
	public boolean assessFirstRowBorderTile(Tile activeTile, int targetCol)
	{
		int i = 0;
		while (i < 4)
		{
			//System.out.println("Assessing ID " + activeTile.getID() + " " + i + ": ");
			
			// check west board tile
			if (activeTile.getDirections()[(i+3)%4] == board[0][targetCol-1].getDirections()[1])
			{
				
				if (activeTile.getDirections()[i] == 0 )
				{
						// a match has been found. apply native rotate based on i and flag up
					if (i%2 == 0)
						activeTile.rotate(i);
					else	// i = 1 or 3
						activeTile.rotate((i+2)%4);
					return true;
			
				}
			}
			i++;
		
		}	// end while
		
		return false;	// tile is discarded
		
	}	// end assessFirstRowBorderTile()
	
	public boolean assessCenterRowBorderTile(Tile activeTile, int targetRow)
	{
		int i = 0;
		while (i < 4)
		{
			//System.out.println("Assessing CRBT ID " + activeTile.getID() + " " + i + ": ");
			
			// check north board tile
			if (activeTile.getDirections()[(i+1)%4] == board[targetRow - 1][0].getDirections()[2])
			{
				if (activeTile.getDirections()[i] == 0 )
				{
						// a match has been found. apply native rotate based on i and flag up
					if (i%2 == 0)
						activeTile.rotate((i+3)%4);
					else	// i = 1 or 3
						activeTile.rotate((i+1)%4);
					return true;
			
				}
			}
			i++;
		
		}	// end while
		
		return false;	// tile is discarded
		
	}	// end assessCenterRowBorderTile()
	
	public boolean assessLastRowBorderTile(int n, Tile activeTile, int targetCol)
	{
		int i = 0;
		while (i < 4)
		{
			//System.out.println("Assessing ID " + activeTile.getID() + " " + i + ": ");
			
			// check west board tile
			if (activeTile.getDirections()[(i+1)%4] == board[n-1][targetCol-1].getDirections()[1])
			{
				if (activeTile.getDirections()[(i+2)%4] == board[n-2][targetCol].getDirections()[2])
				{
					if (activeTile.getDirections()[i] == 0 )
					{
						// a match has been found. apply native rotate based on i and flag up
					if (i%2 == 0)
						activeTile.rotate((i+2)%4);
					else	// i = 1 or 3
						activeTile.rotate(i);
					return true;
			
					}
				}
			}
			i++;
		
		}	// end while
		
		return false;	// tile is discarded
		
	}	// end assessLastRowBorderTile()

	// placeXXXXXRow(Tile, row and/or column)
	
	public boolean placeFirstRow()
	{
		// Choose a random corner tile for the first tile
		Random r = new Random();
  		int q = r.nextInt(4) + 1;
  		while (q > 0)
  		{		
  			cornerBag.add(cornerBag.poll());
  			--q;
  		}
  		
  		Tile first = cornerBag.poll();
  		
  		// Place the tile in valid orientation
  		while(true)
  		{
  			if (first.getDirections()[0] == 0 && first.getDirections()[3] == 0)
  				break;
  			else
  				first.rotate(1);
  		}
  		placeTile(first,  0,  0);
  		
  		// Place the next n - 2 tiles
  		for (int i = 1; i <= size-2; i++)
  		{
  			// Exhaust tile bag if necessary
  			for(int j = 1; j <= borderBag.size(); j++)
  			{
  				Tile activeTile = borderBag.poll();
  			
  				if (assessFirstRowBorderTile(activeTile, i))
  				{	
  					placeTile(activeTile, 0, i);
  					break;
  				}
  				else
  					borderBag.add(activeTile);
  				
  				// No good border pieces
  				if (j == borderBag.size())
  					return false;
  			}
  				
  		}

  		// place second corner piece
  		int k = 1;
  		while(k <= cornerBag.size())				
  		{
  			Tile activeTile = cornerBag.poll();
  			
				if (assessFirstRowBorderTile(activeTile, size - 1))
				{	
					placeTile(activeTile, 0, size - 1);
					return true;
				}
				
				else
				{
					cornerBag.add(activeTile);
					++k;
				}
				
  		}
  		
  		// no valid second corner piece
  		return false;
	}		// end place first row
	
	public boolean placeCenterRow(int thisRow)
	{
		
		// Place left border piece
		
		int k = 1;
  		while(k <= borderBag.size())
  		{
  			Tile activeTile = borderBag.poll();
  			
			if (assessCenterRowBorderTile(activeTile, thisRow))
			{	
				placeTile(activeTile, thisRow, 0);
				break;
			}
			
			else
			{
				borderBag.add(activeTile);
				if(++k == borderBag.size())
					return false;
			}
  		}
		
  		
  		// Place the next n - 2 tiles
  		for (int i = 1; i <= size-2; i++)
  		{
  			// Exhaust tile bag if necessary
  			for(int j = 1; j <= centerBag.size(); j++)
  			{
  				Tile activeTile = centerBag.poll();
  			
  				if (assessCenterTile(activeTile, thisRow, i))
  				{	
  					placeTile(activeTile, thisRow, i);
  					//System.out.println("placed tile " + i + " on attempt " + j);
  					break;
  				}
  				
  				else
  				{
  					centerBag.add(activeTile);
  					if (j == centerBag.size())
  						return false;
  				}
  			}
  				
  		}
  		// finished placing n-2 tiles
  		// place second border piece
  		
  		int k2 = 1;
  		while(k2 <= borderBag.size())				
  		{
  			Tile activeTile = borderBag.poll();
  			
				if (assessCenterTile(activeTile, thisRow, size - 1))
				{	
					placeTile(activeTile, thisRow, size - 1);
					return true;
				}
				
				else
				{
					borderBag.add(activeTile);
					++k2;
				}
				
  		}
  		
  		return false;
  		
	}		// end placeCenterRow
	

	public boolean placeLastRow()
	{
		
		// place first corner tile
		//System.out.println("Placing 3rd corner piece");
		boolean ncFlag = true;
		for (int i = 1; i <= 2; i++)
		{
			Tile activeTile = cornerBag.poll();
			if(assessCenterRowBorderTile(activeTile, size - 1))
			{
				this.placeTile(activeTile, size - 1, 0);
				ncFlag = false;
				break;
			}
			
			else
				cornerBag.add(activeTile);
		}
		
		if(ncFlag)
		{
			//System.out.println("No 3rd corner piece found");
			return false;
		}
		
  		// Place the next n - 2 tiles
  		for (int i = 1; i <= size-2; i++)
  		{
  			
  			shuffleBag(borderBag);
  			
  			// Exhaust tile bag if necessary
  			for(int j = 1; j <= borderBag.size(); j++)
  			{
  				Tile activeTile = borderBag.poll();
  			
  				if (assessLastRowBorderTile(size, activeTile, i))
  				{	
  					placeTile(activeTile, size - 1, i);
  					break;
  				}
  				else
  					borderBag.add(activeTile);
  				
  				if (j == borderBag.size())
  				{
  				// No candidate
  		  			//System.out.println("Ran out of border pieces...");
  		  			return false;
  				}
  			}
  		}
  		// finished placing n-2 tiles by sheer luck (or something)
  		
  		// place last puzzle piece???
  		
  		Tile activeTile = cornerBag.poll();
  			
		if (assessLastRowBorderTile(size, activeTile, size - 1))
		{	
			placeTile(activeTile, size - 1, size - 1);
			return true;
		}
			
		else
		{
			//System.out.println("So close!");
			cornerBag.add(activeTile);
			return false;
		}
				
  		
	}		// end place last row
	
	public void removeRow(int row)
	{
		int col = 0;
		
		// Row is the top or bottom row
		if (row == 0 || row == size - 1)
		{
			if (board[row][col] != null)
			{
				cornerBag.add(board[row][col]);
				board[row][col++] = null;
				piecesPlaced--;
			}
			
			
			while(board[row][col] != null)
			{
				if(col == size - 1)
					cornerBag.add(board[row][col]);
				else
					borderBag.add(board[row][col]);
				
				
				board[row][col++] = null;
				piecesPlaced--;
				if(col == size)
					break;
			}
		}
		
		// Row does not contain corner pieces
		else
		{
			if (board[row][col] != null)
			{
				borderBag.add(board[row][col]);
				board[row][col++] = null;
				piecesPlaced--;
			}
				
			while(board[row][col] != null)
			{
				if(col == size - 1)
					borderBag.add(board[row][col]);
				else
					centerBag.add(board[row][col]);
				
				board[row][col++] = null;
				piecesPlaced--;
				if(col == size)
					break;
			}
		}
	}		// end remove row
	
	// for improved bactracking
	public void removeMultipleRows(int startIdx, int numberOfRows)
	{
		for (int i = 0; i <= numberOfRows - 1; i++)
			this.removeRow(startIdx - i);
		
		shuffleBag(centerBag);
	}
	
	public void clearBoard()
	
	{
		int i = 0;
		
		while (board[i][0] != null)
		{
			if (i == size - 1)
			{
				removeRow(i);
				break;
			}
			
			else
				removeRow(i);
				
			i++;
		}
			
			
	}	// end clearBoard()
	
	// hardcoded time values should scale. Careful! This controls how long
	// the program runs
	public boolean killSwitch(Stopwatch killTimer, double timeCoeff, String debug)
	{
		if (killTimer.elapsedTime("m") == (double)(10000 * timeCoeff) && timeWarning[0] == false)
		{
			System.out.println(debug + "Time is ticking...");
			timeWarning[0] = true;
		}
			
		else if (killTimer.elapsedTime("m") == 16000 * timeCoeff && timeWarning[1] == false)
		{
			System.out.println(debug + "Time is passing now...");
			timeWarning[1] = true;
		}
		
		else if (killTimer.elapsedTime("m") == 22000 * timeCoeff && timeWarning[2] == false)
		{
			System.out.println(debug + "Time is almost up...");
			timeWarning[2] = true;
		}
		
		else if (killTimer.elapsedTime("m") > 30000 * timeCoeff)
		{
			System.out.println(debug + "Time has run out.");
			return true;
		}
		
		return false;	
	}
	
	public void checkForBestSolve(int iter, Stopwatch Timer)
	{
		if (this.getPiecesPlaced() > bestSolve[1])
		{
			bestSolve[0] = iter;
			bestSolve[1] = this.getPiecesPlaced();
			solveTime = Timer.elapsedTime("m");
			bestBoard = this.getBoard();
		}
	}
	
	public void pollBags(int cornbag, int bordbag, int centbag)
	{
		if (cornbag == 1)
		{
			System.out.println("Corners: " + cornerBag.size());
			for (int i = 1; i <= cornerBag.size(); i++)
			{
				System.out.print(i + " ");
				cornerBag.peek().reportTile();
				cornerBag.add(cornerBag.poll());
			}
		}
		
		if (bordbag == 1)
		{
			System.out.println("Borders: " + borderBag.size());
			for (int i = 1; i <= borderBag.size(); i++)
			{
				System.out.print(i + " ");
				borderBag.peek().reportTile();
				borderBag.add(borderBag.poll());
			}
		}
		
		if (centbag == 1)
		{
			System.out.println("Centers: " + centerBag.size());
			for (int i = 1; i <= centerBag.size(); i++)
			{
				System.out.print(i + " ");
				centerBag.peek().reportTile();
				centerBag.add(centerBag.poll());
			}
		}
		
	}		// end pollBags()
	
	
	public static class Stopwatch
	{
		private final long start;
		
		public Stopwatch()
		{	start = System.currentTimeMillis();	}
		
		public double elapsedTime(String flavour)
		{
			long now = System.currentTimeMillis();
			if (flavour == "m")
				return (now - start);
			else
				return (now - start) / 1000.0;
		}	
	}
	
}		// End GameBoard class
