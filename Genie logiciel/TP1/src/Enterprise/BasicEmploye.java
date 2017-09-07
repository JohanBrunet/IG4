package enterprise;

public class BasicEmploye extends Employe {
	
	private double nbHeures;
	private double tauxHoraire;
	private double tauxHeuresSup;

	public BasicEmploye(String name) {
		super(name);
	}
	
	public BasicEmploye(String name, float nbH, float tauxH, float tauxHS) {
		super(name);
		this.nbHeures = nbH;
		this.tauxHoraire = tauxH;
		this.tauxHeuresSup = tauxHS;
	}
	
	void setInfosSalaire(float nbH, float tauxH, float tauxHS) {
		this.nbHeures = nbH;
		this.tauxHoraire = tauxH;
		this.tauxHeuresSup = tauxHS;
	}
	
	@Override
	double getSalaire() {
		double heuresSup;
		heuresSup = this.nbHeures > 35 ? this.nbHeures - 35 : 0;
		return (this.nbHeures - heuresSup) * this.tauxHoraire + heuresSup * this.tauxHoraire * this.tauxHeuresSup;
	}
	
}
