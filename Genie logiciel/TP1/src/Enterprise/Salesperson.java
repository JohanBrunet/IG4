package enterprise;

public class Salesperson extends Employe {

	private double sommeFixe;
	private double chiffreAffaires;

	public Salesperson(String name) {
		super(name);
	}
	
	public Salesperson(String name, float sommeF, float ca) {
		super(name);
		this.sommeFixe = sommeF;
		this.chiffreAffaires = ca;
	}
	
	public void setInfosSalaire(float sommeF, float ca) {
		this.sommeFixe = sommeF;
		this.chiffreAffaires = ca;
	}

	@Override
	double getSalaire() {
		return this.sommeFixe + 0.01 * this.chiffreAffaires;
	}

}
