/****************************************************************************
 *
 * javaplot.java                                            Laurent Bartholdi
 *
 *   @(#)$Id: javaplot.java,v 1.12 2011/05/01 14:36:59 gap Exp $
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
import java.awt.image.*;
import java.lang.Math;

import jv.geom.*;
import jv.object.PsConfig;
import jv.viewer.PvDisplay;
import jv.vecmath.PdVector;
import jv.objectGui.PsImage;
import jv.number.*;

class TangentP1 {
    public PuComplex z;
    public double dz;
    public TangentP1(PuComplex newz) { z = newz; dz = 1.0; }
    public TangentP1(PuComplex newz, double newdz) { z = newz; dz = newdz; }
}

public class javaplot extends Applet {
	/**
	 * Applet support. Configure and initialize the viewer,
	 * load geometry and add display.
	 */

    public static final long serialVersionUID = 1L;

    static int numlines = 24;
    private int rows, cols, maxiter;
    static PuComplex infinity = new PuComplex(1./0.,1./0.);

    private int projtype = 0;

    private int degree = -1, cyclelen, cycleperiod[], cyclenext[];
    private PuComplex num[], den[], dnum[], dden[], mund[], nedd[], cycle[];
    private String label;

    private Double[] parsedoubles(String line, int num) {
	// hack: sets the global "label" to the first unparsed entry,
	// if it's there
	String fields[] = line.split(" ");
	Double data[] = new Double[fields.length];
	int i;

	for (i = 0; i < num; i++)
	    data[i] = Double.parseDouble(fields[i]);

	if (fields.length > num)
	    label = fields[num];
	else
	    label = "";

	if (projtype != 0) {
	    Double radius = Math.sqrt(data[0]*data[0]+data[1]*data[1]+data[2]*data[2]);
	    for (i = 0; i < 3; i++) data[i] /= radius;
	    if (projtype > 0)
		data[2] = Math.sqrt(0.5+0.5*data[2]);
	    else
		data[2] = -Math.sqrt(0.5-0.5*data[2]);
	    if (data[0] != 0. || data[1] != 0.) {
		double r = Math.sqrt((1.-data[2]*data[2])/(data[0]*data[0]+data[1]*data[1]));
		data[0] *= r; data[1] *= r;
	    }
	    for (i = 0; i < 3; i++) data[i] *= radius;
	}
	return data;
    }

    private static ColorModel colormodel() {
        // Generate 16-color model
        byte[] r = new byte[16];
        byte[] g = new byte[16];
        byte[] b = new byte[16];

        r[0] = 0; g[0] = 0; b[0] = 0;
        r[1] = (byte)255; g[1] = (byte)255; b[1] = (byte)255;

        r[2] = (byte)192; g[2] = (byte)255; b[2] = (byte)255;
        r[3] = (byte)255; g[3] = (byte)192; b[3] = (byte)255;
        r[4] = (byte)255; g[4] = (byte)255; b[4] = (byte)192;

        r[5] = (byte)192; g[5] = (byte)192; b[5] = (byte)255;
        r[6] = (byte)192; g[6] = (byte)255; b[6] = (byte)192;
        r[7] = (byte)255; g[7] = (byte)192; b[7] = (byte)192;

        r[8] = (byte)192; g[8] = (byte)192; b[8] = (byte)192;

        r[9] = (byte)224; g[9] = (byte)255; b[9] = (byte)255;
        r[10] = (byte)255; g[10] = (byte)224; b[10] = (byte)255;
        r[11] = (byte)255; g[11] = (byte)255; b[11] = (byte)224;

        r[12] = (byte)224; g[12] = (byte)224; b[12] = (byte)255;
        r[13] = (byte)224; g[13] = (byte)255; b[13] = (byte)224;
        r[14] = (byte)255; g[14] = (byte)255; b[14] = (byte)224;

        r[15] = (byte)224; g[15] = (byte)224; b[15] = (byte)224;

        return new IndexColorModel(4, 16, r, g, b);
    }

    private PuComplex evalf (PuComplex z) {
	PuComplex n, d;
	if (z.equals(infinity)) {
	    n = new PuComplex(num[degree]);
	    d = new PuComplex(den[degree]);
	} else if (z.sqrAbs() <= 1.) {
	    n = new PuComplex(num[degree]);
	    d = new PuComplex(den[degree]);
	    for (int i = degree-1; i >= 0; i--) {
		n.mult(z).add(num[i]);
		d.mult(z).add(den[i]);
	    }
	} else {
	    PuComplex iz = PuComplex.inv(z);
	    n = new PuComplex(num[0]);
	    d = new PuComplex(den[0]);
	    for (int i = 1; i <= degree; i++) {
		n.mult(iz).add(num[i]);
		d.mult(iz).add(den[i]);
	    }
	}
	if (d.sqrAbs()==0.)
	    return infinity;
	return n.div(d);
    }

    private PuComplex evalpoly (PuComplex z, PuComplex poly[], int d) {
	PuComplex w = new PuComplex(poly[d]);
	for (int i = d-1; i >= 0; i--)
	    w.mult(z).add(poly[i]);
	return w;
    }
    private PuComplex yloplave (PuComplex z, PuComplex poly[], int d) {
	PuComplex w = new PuComplex(poly[0]);
	for (int i = 1; i <= d; i++)
	    w.mult(z).add(poly[i]);
	return w;
    }

    private TangentP1 evalfdf (TangentP1 v) {
	// z is a point on the sphere -- complex or infinity
	// dz is the norm of a vector in the tangent space,
	// normalized by 1/(1+|z|^2)
	// in that normalization, |dz| is a length on the sphere
	// return the new value f(z), and the new tangent vector |dz|;
	// in effect, return f(z) and dz*f'(z)*(1+|z|^2)/(1+|f(z)|^2)
	PuComplex n, d;
	double dz = v.dz;
	// compute f(z) = n/d without division;
	// and f'(z) = dz, avoiding 0/0 as much as possible
	double znorm = v.z.sqrAbs();
	if (v.z.sqrAbs() <= 1.) {
	    n = evalpoly(v.z,num,degree);
	    d = evalpoly(v.z,den,degree);
	    dz *= (1.+znorm)*evalpoly(v.z,dnum,degree-1).mult(d).sub(evalpoly(v.z,dden,degree-1).mult(n)).abs();
	} else {
	    PuComplex iz;
	    if (v.z.equals(infinity))
		iz = PuComplex.ZERO;
	    else
		iz = PuComplex.inv(v.z);
	    n = yloplave(iz,num,degree);
	    d = yloplave(iz,den,degree);
	    dz *= (1.+iz.sqrAbs())*yloplave(iz,mund,degree-1).mult(d).sub(yloplave(iz,nedd,degree-1).mult(n)).abs();
	}
	double dsqr = d.sqrAbs();
	dz /= n.sqrAbs()+dsqr;

	if (dsqr==0.)
	    return new TangentP1(infinity,dz);
	else
	    return new TangentP1(PuComplex.div(n,d),dz);
    }

    private double spheredist (PuComplex z, PuComplex w) {
	if (z.equals(infinity) && w.equals(infinity))
	    return 0.;
	if (z.equals(infinity))
	    return 2./w.abs();
	if (w.equals(infinity))
	    return 2./z.abs();
	return 2.*PuComplex.sub(z,w).abs()/Math.sqrt((1.+z.sqrAbs())*(1.+w.sqrAbs()));
    }

    private void julia (int data[]) {
	// TangentP1 z1 = new TangentP1(new PuComplex(0.,0.1), 1.);for (int i = 0; i < 10; i++) { System.out.print(z1.z); System.out.printf(" %g\n",z1.dz); z1 = evalfdf(z1);}

	for (int r = 0; r < rows; r++) {
	    long rskip = Math.round(Math.floor(1. / Math.sin(r*Math.PI/rows)));
	    double zproj = Math.sin(r*Math.PI/rows) / (Math.cos(r*Math.PI/rows)+1.);
	    if (rskip < 0 || rskip > rows) rskip=rows; // infinity value

	    for (int c = 0; c < cols; c += rskip) {
		PuComplex z0 = new PuComplex(Math.cos(c*2*Math.PI/cols)*zproj,Math.sin(c*2*Math.PI/cols)*zproj);
		TangentP1 v = new TangentP1(z0,4.0/cols);
		int color = 0; // by default, julia
		for (int iter = 0; iter < maxiter; iter++) {
		    v = evalfdf(v);

		    if (spheredist(z0,v.z)<v.dz) {
			color = 0;
			break;
		    }

		    for (int i = 0; i < cyclelen; i++) {
			if (spheredist(v.z,cycle[i]) < 1e-6) {
			    while (iter % cycleperiod[i] != 0) {
				i = cyclenext[i];
				iter++;
			    }
			    color = 1+(i % 15);
			    iter = maxiter;
			    break;
			}
		    }
		}
		for (int cc = c; cc < c+rskip && cc < cols; cc++)
		    data[cols*r+cc] = color;
	    }
	}
    }

    public void init() {
	// useless, too late!
	// System.setSecurityManager(new SecurityManager()); 

	PsConfig.init(this, null);

	BufferedReader stdin = new BufferedReader(new InputStreamReader(System.in));
	
	PvDisplay disp = new PvDisplay();
	String imagefile = "";

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

	    if (readline.equals("UPPER")) {
		projtype = 1;
		readline = stdin.readLine();
	    }
	    if (readline.equals("LOWER")) {
		projtype = -1;
		readline = stdin.readLine();
	    }

	    String line[] = readline.split(" ");
	    if (line[0].equals("IMAGE")) {
		imagefile = line[1];
		readline = stdin.readLine();
		line = readline.split(" ");
	    }
	    if (line[0].equals("FUNCTION")) {
		degree = (line.length-1)/4-1;
		num = new PuComplex[degree+1];
		den = new PuComplex[degree+1];
		dnum = new PuComplex[degree];
		dden = new PuComplex[degree];
		mund = new PuComplex[degree];
		nedd = new PuComplex[degree];

		for (int i = 0; i <= degree; i++) {
		    num[i] = new PuComplex(Double.parseDouble(line[1+2*i]),Double.parseDouble(line[1+2*i+1]));
		    den[i] = new PuComplex(Double.parseDouble(line[1+2*(degree+1)+2*i]),Double.parseDouble(line[1+2*(degree+1)+2*i+1]));
		}
		for (int i = 0; i < degree; i++) {
		    dnum[i] = PuComplex.mult(num[i+1],i+1);
		    dden[i] = PuComplex.mult(den[i+1],i+1);
		    mund[i] = PuComplex.mult(num[i],i-degree);
		    nedd[i] = PuComplex.mult(den[i],i-degree);
		}

		readline = stdin.readLine();
		line = readline.split(" ");
		if (!line[0].equals("CYCLES")) {
		    System.out.println("No CYCLES entry!\n");
		    System.exit(-1);
		}
		cyclelen = (line.length-1)/4;
		cycle = new PuComplex[cyclelen];
		cyclenext = new int[cyclelen];
		cycleperiod = new int[cyclelen];
		for (int i = 0; i < cyclelen; i++) {
		    if (line[1+4*i].equals("Infinity"))
			cycle[i] = infinity;
		    else
			cycle[i] = new PuComplex(Double.parseDouble(line[1+4*i]),Double.parseDouble(line[1+4*i+1]));
		    cyclenext[i] = Integer.parseInt(line[1+4*i+2]);
		    cycleperiod[i] = Integer.parseInt(line[1+4*i+3]);
		}
		readline = stdin.readLine();
		line = readline.split(" ");
		if (!line[0].equals("IMAGE")) {
		    System.out.println("No IMAGE entry!\n");
		    System.exit(-1);
		}
		rows = Integer.parseInt(line[1]);
		cols = 2*rows;
		maxiter = Integer.parseInt(line[2]);
		
		readline = stdin.readLine();
		line = readline.split(" ");
	    }
	    if (!line[0].equals("POINTS")) {
		System.out.println("No POINTS <numpoints> entry!\n");
		System.exit(-1);
	    }
	    int numv = Integer.parseInt(line[1]);
	    geom.setNumVertices(numv);
	    for (int i=0; i<numv; i++) {
		Double data[] = parsedoubles(stdin.readLine(),4);
		geom.setVertex(i, data[0], data[1], data[2]);
		geom.setVertexSize(i, data[3]);
		geom.getVertex(i).setName(label);
	    }
	    geom.showVertexSizes(true);
	    geom.setEnabledIndexLabels(true);
	    geom.showVertexLabels(true);

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
	    int numa = Integer.parseInt(line[1]);
	    for (int i=0; i<numa; i++) {
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
		geom.setGlobalEdgeSize(2.);
		geom.showVertices(false);
		for (int j=0; j<len; j++) {
		    Double data[] = parsedoubles(stdin.readLine(),3);
		    geom.setVertex(j, data[0], data[1], data[2]);
		}
		disp.addGeometry(geom);
	    }
	} catch(IOException e) {}

	{
	    PgElementSet geom = new PgElementSet(3);
	    geom.setTransparency(0.2);
	    geom.setName("Central Sphere");
	    geom.computeSphere(numlines,numlines,0.99);
	    geom.showTransparency(true);
	    geom.showEdges(false);
	    geom.setGlobalElementColor(Color.white);
	    Image image = null;

	    if (!imagefile.equals("")) {
		PsImage psimage = new PsImage(imagefile);
		if (psimage != null) {
		    psimage.loadImage();
		    image = psimage.getImage();
		}
	    }

	    if (degree >= 2) {
		int imagedata[] = new int[rows*cols];
		julia(imagedata);
		image = createImage(new MemoryImageSource(cols, rows,
		    colormodel(), imagedata, 0, cols));
	    }

	    if (image != null) {
		geom.setDimOfTextures(2);
		geom.assureVertexTextures();
		geom.showVertexTexture(true);

		// Generate texture coordinates in [0,1]*[0,1]
		PdVector [] texCoord = geom.getVertexTextures();
		double uFac = 1./(-1.+numlines);
		double vFac = 1./(-1.+numlines);
		int ind = 0;
		for (int i=0; i<numlines; i++) {
		    double u = uFac*i;
		    for (int j=0; j<numlines; j++) {
			double v = vFac*j;
			texCoord[ind].m_data[0] = u;
			texCoord[ind].m_data[1] = v;
			ind++;
		    }
		}
		PgTexture texture = new PgTexture();
		texture.setImage(image);
		geom.setTexture(texture);
		geom.update(geom);
	    }	    

	    disp.addGeometry(geom);
	}

	if(false) {
	    PgPointSet geom = new PgPointSet(3);
	    geom.setName("zero");
	    geom.setNumVertices(1);
	    geom.setVertex(0,1.5,0.,0.);
	    geom.showVertexLabels(true);

	    disp.addGeometry(geom);
	}
	
	setLayout(new BorderLayout());
	add(disp, BorderLayout.CENTER);
    }
}
