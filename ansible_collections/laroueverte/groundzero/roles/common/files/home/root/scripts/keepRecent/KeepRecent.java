import java.io.*;
public class KeepRecent {
	public static void usage() {
		System.out.println("Usage:");
		System.out.println("KeepRecent directoryi nbAGarder [startsWith endsWith | EMPTY ]");
	}

	public static void main(String[] args) {
		if (args.length<2) {
			usage();
			System.exit(1);
		}
		String startsWith = "backup";
		String endsWith = ".sql";

		if (args.length > 2) {
			if (args.length!=4) {
				usage();
				System.exit(1);
			}
			startsWith = args[2];
			endsWith = args[3];
		}
		if (endsWith.equals("EMPTY"))
			endsWith = "";
		File dir = new File(args[0]);
		int nbKeep = Integer.parseInt(args[1]);
		System.out.println("Keeping the most "+nbKeep+" recent files from the directory "+dir.getAbsolutePath());

		if (!dir.exists()) {
			System.out.println("Le dossier n'existe pas!!!");
			System.exit(1);
		}

		final String startsWithFilter = startsWith;
		final String endsWithFilter = endsWith;
		FilenameFilter filter = new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.startsWith(startsWithFilter) && name.endsWith(endsWithFilter);
			};
		};
		File[] files = dir.listFiles(filter);
		java.util.Arrays.sort(files);
		if (files.length<=nbKeep) {
			 System.out.println("Pas de fichier à supprimer, moins de "+nbKeep+" présents");
			 System.exit(0);
		}
		for (int i=0; i<files.length-nbKeep; i++) {
			System.out.println("Suppression de "+files[i].getName());
			files[i].delete();
		}

		System.exit(0);

		
	}

}
