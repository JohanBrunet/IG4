package enterprise;

public abstract class Employe {
	private String name;
	
	public Employe (String name) {
		this.name = name;
	}
	
	public String getName() {
		return this.name;
	}
	
	abstract double getSalaire();
}
