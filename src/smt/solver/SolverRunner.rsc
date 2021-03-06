module smt::solver::SolverRunner

import smt::solver::Z3;

import List;
import String;
import Boolean;
import IO;
import Map;

alias SolverPID = int;

SolverPID startSolver() {
	pid = startZ3();
	
	// make sure that the unsatisfiable core are produced
	runSolver(pid, "(set-option :produce-unsat-cores true)");
	
	return pid;
}

void stopSolver(SolverPID pid) {
	stopZ3(pid);
}

bool isSatisfiable(SolverPID pid, str smtFormula) { 
	str solverResult = runSolver(pid, "(push)
	                                   '<smtFormula>"); 
	if ("" !:= solverResult) {
		throw "Unable to assert clauses: <solverResult>"; 
	} 	
	
	bool sat = checkSat(pid);
	
	runSolver(pid, "(pop)");
	
	return sat;
}

bool checkSat(SolverPID pid) {
	switch(runSolver(pid, "(check-sat)")) {
		case "sat" : return true;
		case "unsat": return false;
		case "unknown": throw "Could not compute satisfiability";		
	}
}

str runSolver(SolverPID pid, str commands) {
	try {
		return run(pid, commands, debug=true);
	}
	catch er: throw "Error while running SMT solver, reason: <er>"; 	
}
