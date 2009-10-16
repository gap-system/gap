/****************************************************************************
 *
 * javaplot.java                                            Laurent Bartholdi
 *
 *   @(#)$Id: javaplot.java,v 1.5 2009/10/13 09:37:06 gap Exp $
 *
 * Copyright (C) 2009, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * prepare data for the javaplot 3d plotting package
 *
 ****************************************************************************/
import java.applet.Applet;
import java.awt.*;
import java.io.*;

import jv.geom.*;
import jv.object.PsConfig;
import jv.viewer.PvDisplay;

public class javaplot extends Applet {
	/**
	 * Applet support. Configure and initialize the viewer,
	 * load geometry and add display.
	 */
    public static final long serialVersionUID = 1L;

    public void init() {
	// useless, too late!
	// System.setSecurityManager(new SecurityManager()); 

	PsConfig.init(this, null);

	BufferedReader stdin = new BufferedReader(new InputStreamReader(System.in));
	
	PvDisplay disp = new PvDisplay();
	
	try {
	    PgPointSet geom = new PgPointSet(3);
	    geom.setName("Julia Set");

	    String readline = stdin.readLine();
	    if (readline == null) {
		System.out.println("No POINTS entry!\n");
		System.exit(-1);
	    }
	    while (readline.equals("c"))
		readline = stdin.readLine();

	    String line[] = readline.split(" ");
	    if (!line[0].equals("POINTS")) {
		System.out.println("No POINTS <numpoints> entry!\n");
		System.exit(-1);
	    }
	    int num = Integer.parseInt(line[1]);
	    geom.setNumVertices(num);
	    for (int i=0; i<num; i++) {
		line = stdin.readLine().split(" ");
		geom.setVertex(i, Double.parseDouble(line[0]), Double.parseDouble(line[1]), Double.parseDouble(line[2]));
		geom.setVertexSize(i, Double.parseDouble(line[3]));
	    }
	    geom.showVertexSizes(true);

	    // Why not, just assign some colors.
	    geom.setGlobalVertexColor(Color.black);
	    geom.showVertexColors(true);
	
	    // Register the geometry in the display, and make it active.
	    disp.addGeometry(geom);
	} catch(IOException e) {}

	try {
	    String readline = stdin.readLine();
	    if (readline == null) {
		System.out.println("No ARCS entry!\n");
		System.exit(-2);
	    }
	    String line[] = readline.split(" ");
	    if (!line[0].equals("ARCS")) {
		System.out.println("No ARCS <numarcs> entry!\n");
		System.exit(-2);
	    }
	    int num = Integer.parseInt(line[1]);
	    for (int i=0; i<num; i++) {
		line = stdin.readLine().split(" ");
		if (!line[0].equals("ARC")) {
		    System.out.println("No ARC <length> <R> <G> <B> entry!\n");
		    System.exit(-3);
		}
		int len = Integer.parseInt(line[1]);
		PgPolygon geom = new PgPolygon(3);
		geom.setNumVertices(len);
		geom.setName("Arc #"+i);
		geom.setGlobalEdgeColor(new Color(Integer.parseInt(line[2]), Integer.parseInt(line[3]), Integer.parseInt(line[4])));
		geom.setGlobalEdgeSize(2.0);
		geom.showVertices(false);
		for (int j=0; j<len; j++) {
		    line = stdin.readLine().split(" ");
		    geom.setVertex(j, Double.parseDouble(line[0]), Double.parseDouble(line[1]), Double.parseDouble(line[2]));
		}
		disp.addGeometry(geom);
	    }
	} catch(IOException e) {}

	{
	    PgElementSet geom = new PgElementSet(3);
	    geom.setTransparency(0.2);
	    geom.setName("Central Sphere");
	    geom.computeSphere(24,24,0.99);
	    geom.showTransparency(true);
	    geom.showEdges(false);
	    geom.setGlobalElementColor(Color.white);
	    
	    disp.addGeometry(geom);
	}

	if(false) {
	    PgPointSet geom = new PgPointSet(3);
	    geom.setName("zero");
	    geom.setNumVertices(1);
	    geom.setVertex(0,1.5,0.0,0.0);
	    geom.showVertexLabels(true);

	    disp.addGeometry(geom);
	}
	
	setLayout(new BorderLayout());
	add(disp, BorderLayout.CENTER);
    }
}
