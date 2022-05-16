import java.util.Scanner;

public class E_II_Driver 
{
	public static void main(String[] args) 
	{
		// Official stuff
		System.out.println("Coffee and Exhaustion, LLC. presents:");
		System.out.println("Jamie FC's Eternity II Solver v3.2b");
		System.out.println("Concordia Student ID 40195531");
		System.out.println("I attest that this is my own work and nobody else\'s.");
		
		Scanner userIn = new Scanner(System.in);
		
		// user menu
		while(true)
		{
				
			// Grab Board Size
			System.out.println("\nNEW GAME\n\nChoose an integer board size from n = 2 to n = 16: ");
			int USER_SIZE = 0;
			while(USER_SIZE < 2 || USER_SIZE > 16)
				USER_SIZE = userIn.nextInt();
			
			// Sorry, I'm in electrical
			if (USER_SIZE == 9)
				System.out.println("\nWARNING: For n = 9 (and only n = 9) there is an unidentified " +
				"bug that causes the solver to hang about 20% of the time.\n" +
				"Please restart the program if the solver runs too long.\n");
						
			
			// Iteration Depth
			System.out.println("How many solve iterations? ");
			System.out.println("0 = many      1 = lots    2 = lots and lots      3 = exhaustion++");
			int iterz = -1;
			while(iterz < 0 || iterz > 3)
				iterz = userIn.nextInt();			// "rough gain" on iterations
			int iters = 2000 + (4000 * iterz);		// can be further modified in solve()
			
			// Solve Cycle Running Time
			System.out.println("How long will you wait for a full solve routine?");
			System.out.println("0 = 30s OR exit on first solve    1 = standard    2 = long   3 = coffee break (120s)");
			System.out.println("Choose one: ");
			int depth = -1;
			while(depth < 0 || depth > 3)
				depth = userIn.nextInt();
			
			// Backtrack Depth
			System.out.println("Select style of backtrack");
			System.out.println("0 = single row: shallow solve, more iterations/second");
			System.out.println("1 = multiple row: deeper solve, fewer iterations/second");
			System.out.println("2 = multiple row with replenishment: very deep solves");
			System.out.println("Choose one: ");
			int bktk = -1;
			while(bktk < 0 || bktk > 2)
				bktk = userIn.nextInt();
			
			// Level of Output Detail
			System.out.println(" + + Solver is ready! + +\nHow detailed would you like your output?");
			System.out.println("0 = no output except best solution and timer notifications");
			System.out.println("1 = same + iteration progress + \"solution found\" notifications");
			System.out.println("2 = same + a collection of full solutions");
			System.out.println("3 = same + iteration number (not recommended for n < 10)");
			System.out.println("Choose one: ");
			int detail = -1;
			while(detail < 0 || detail > 3)
				detail = userIn.nextInt();
			
			
			
			// MAIN SOLVE ROUTINE
			GameBoard newGame = new GameBoard(USER_SIZE);
			newGame.solve(iters, detail, depth, bktk);
	  		
	  		// Re-run menu or terminate
	  		System.out.print("End of solve routine. Solve another? (y/n)_ ");
	  		String again = userIn.next();
	  		if (again.equals("y") || again.equals("Y") || again.equals("yes") || 
	  			again.equals("Yes") || again.equals("YES"))
	  			continue;
	  		else 
	  			break;
	  				//.(Heart)
		}	// end menu
  		
		// Terminate
		userIn.close();
		System.out.println("\nThis class was amazing. Thank you so much for everything!  ~ JFC");
		
	}	// end main
	
}		// end driver class
