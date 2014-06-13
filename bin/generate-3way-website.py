#! /usr/bin/env python
import screed
import csv
import os
import sys
sys.path.insert(0, '/u/t/dev/blastparser')
import blastparser
from cPickle import load, dump
import textwrap

HOMOLOG_CUTOFF = 1e-12
names = { 'fig|6666666.20750': 'Ofp1_A',
          'fig|6666666.20450': 'Ofp2',
          'fig|207954.7': 'neptunii' }

def read_subsystem(filename):
    x = []
    fp = open(filename)
    r = csv.reader(fp, delimiter='\t')
    for (category, subcategory, subsystem, role, features) in r:
        x.append((category, subcategory, subsystem, role, features))

    return x[1:]

def make_genes_with_subsystems(subsystem_data):
    gws = {}

    for a, b, c, d, genes in subsystem_data:
        genes = genes.split(',')
        genes = [ x.strip() for x in genes ]
        for gene in genes:
            x = gws.get(gene, [])
            x.append((a,b,c,d))
            gws[gene] = x

    return gws

dirname = '/scratch/qingpeng/3_Goffredi/1119/'

htmldir = '/u/qingpeng/.html/osedax/'
#cogsdir = '/u/t/dev/goffredi2/cog/'
cogsdir = '/scratch/qingpeng/3_Goffredi/Websites/goffredi2/cog/'

cogs_file = cogsdir + 'cogs.pickle'
cogs_names, cogs_by_genes, genes_by_cogs = load(open(cogs_file))


genome1_file = dirname + 'Ofp1_A.faa'
genome1_annot = dirname + 'Ofp1_A.tsv'
genome1_seqs = dict(( (record.name, record.sequence) for record \
                          in screed.open(genome1_file)) )
genome1_cogs = load(open(cogsdir + 'Ofp1_A.cogs.pickle'))

b1v2 = dirname + 'Ofp1_A_against_Ofp2.blastp'
assert os.path.exists( b1v2)
b1v3 = dirname + 'Ofp1_A_against_neptu.blastp'
assert os.path.exists( b1v3)

genome2_file = dirname + 'Ofp2.faa'
genome2_annot = dirname + 'Ofp2.tsv'
genome2_seqs = dict(( (record.name, record.sequence) for record \
                          in screed.open(genome2_file)) )
genome2_cogs = load(open(cogsdir + 'Ofp2.cogs.pickle'))

b2v1 = dirname + 'Ofp2_against_Ofp1_A.blastp'
assert os.path.exists( b2v1)
b2v3 = dirname + 'Ofp2_against_neptu.blastp'
assert os.path.exists( b2v3)

genome3_file = dirname + 'neptu.faa'
genome3_annot = dirname + 'neptu.tsv'
genome3_seqs = dict(( (record.name, record.sequence) for record \
                          in screed.open(genome3_file)) )
genome3_cogs = load(open(cogsdir + 'neptu.cogs.pickle'))

b3v1 = dirname + 'neptu_against_Ofp1_A.blastp'
assert os.path.exists( b3v1)
b3v2 = dirname + 'neptu_against_Ofp2.blastp'
assert os.path.exists( b3v2)

###

genome1_features = read_subsystem(genome1_annot)
g1_genes_with_subsystems = make_genes_with_subsystems(genome1_features)

genome2_features = read_subsystem(genome2_annot)
g2_genes_with_subsystems = make_genes_with_subsystems(genome2_features)

genome3_features = read_subsystem(genome3_annot)
g3_genes_with_subsystems = make_genes_with_subsystems(genome3_features)

###

def calc_orthologs(ab_blast, ba_blast):

    ab = {}
    ab_homologs = {}
    for record in blastparser.parse_file(ab_blast):
        print record.query_name
        x = []
        y = []
        best_bits = None
        for hit in record.hits:
            for match in hit.matches:
                if match.expect > HOMOLOG_CUTOFF: break

                if best_bits is None:
                    best_bits = match.expect

                if best_bits == match.expect:
                    print record.query_name, hit.subject_name, match.expect, best_bits, ab_blast
                    x.append(hit.subject_name)
                y.append(hit.subject_name)

        if x:
            assert y
            ab[record.query_name] = x
        if y:
            ab_homologs[record.query_name] = y

    ba = {}
    ba_homologs = {}
    for record in blastparser.parse_file(ba_blast):
        x = []
        y = []
        best_bits = None
        for hit in record.hits:
            for match in hit.matches:
                if match.expect > HOMOLOG_CUTOFF: break
                if best_bits is None:
                    best_bits = match.expect

                if best_bits == match.expect:
                    x.append(hit.subject_name)
                y.append(hit.subject_name)
                    

        if x:
            assert y
            ba[record.query_name] = x
        if y:
            ba_homologs[record.query_name] = y

    ab_ortho = {}
    ba_ortho = {}

    for a in ab:
        for b in ab[a]:
            if a in ba.get(b, []):
                x = ab_ortho.get(a, [])
                x.append(b)
                ab_ortho[a] = x

                x = ba_ortho.get(b, [])
                x.append(a)
                ba_ortho[b] = x

    return ab_ortho, ba_ortho, ab_homologs, ba_homologs

try:
    print 'loading orthologs, 1 to 2'
    ortho_12, ortho_21, homo_12, homo_21 = load(open('ortho_12.pickle'))
except IOError:
    print 'calculating orthologs, 1 to 2'
    ortho_12, ortho_21, homo_12, homo_21 = calc_orthologs(b1v2, b2v1)

    fp = open('ortho_12.pickle', 'w')
    dump((ortho_12, ortho_21, homo_12, homo_21), fp)

assert ortho_12

try:
    print 'loading orthologs, 2 to 3'
    ortho_23, ortho_32, homo_23, homo_32 = load(open('ortho_23.pickle'))
except IOError:
    print 'calculating orthologs, 1 to 2'
    ortho_23, ortho_32, homo_23, homo_32 = calc_orthologs(b2v3, b3v2)

    fp = open('ortho_23.pickle', 'w')
    dump((ortho_23, ortho_32, homo_23, homo_32), fp)

assert ortho_23

try:
    print 'loading orthologs, 1 to 3'
    ortho_13, ortho_31, homo_13, homo_31 = load(open('ortho_13.pickle'))
except IOError:
    print 'calculating orthologs, 1 to 2'
    ortho_13, ortho_31, homo_13, homo_31 = calc_orthologs(b1v3, b3v1)

    fp = open('ortho_13.pickle', 'w')
    dump((ortho_13, ortho_31, homo_13, homo_31), fp)

assert ortho_13

###

try:
    os.mkdir(htmldir)
except OSError:
    pass

def preprocess_name(gene):
    x = gene.split('.')
    species = ".".join(x[:2])
    
    name = names.get(species, species) + '::'
    name += ".".join(x[2:])

    return name

def preprocess_namelist(x):
    if x:
        x = [ preprocess_name(a) for a in sorted(x) ]
        x = [ gene_link(name) for name in x ]
        return " ".join(x)
    else:
        return '<i>none</i>'

def gene_link(name):
    return "<A href='%s-report.html'>%s</a>" % (name.replace('::', 'XX'), name)

def category_link(cat):
    return "<a href='category-%s.html'>%s</a>" % (cat, cat)

def subcategory_link(cat, subcat):
    return "<a href='subcategory-%sXX%s.html'>%s</a>" % (cat, subcat, subcat)

def subsystem_link(cat, subcat, subsys):
    return "<a href='subsys-%sXX%sXX%s.html'>%s</a>" % (cat, subcat, subsys, subsys)

def role_link(url, role):
    return "<a href='%s.html'>%s</a>" % (url, role)



cats = set()
subcats = set()
subsyses = set()
roles = set()
for _, v in g1_genes_with_subsystems.items():
    for (cat, subcat, subsys, role) in v:
        cats.add(cat)
        subcats.add((cat, subcat))
        subsyses.add((cat, subcat, subsys))
        roles.add((cat, subcat, subsys, role))

for _, v in g2_genes_with_subsystems.items():
    for (cat, subcat, subsys, role) in v:
        cats.add(cat)
        subcats.add((cat, subcat))
        subsyses.add((cat, subcat, subsys))
        roles.add((cat, subcat, subsys, role))

for _, v in g3_genes_with_subsystems.items():
    for (cat, subcat, subsys, role) in v:
        cats.add(cat)
        subcats.add((cat, subcat))
        subsyses.add((cat, subcat, subsys))
        roles.add((cat, subcat, subsys, role))

print cats
print len(subcats)
print len(subsyses)
print len(roles)

cat_d = {}
for cat in cats:
    cat_d[cat] = ([], [], [])

subcat_d = {}
for (cat, subcat) in subcats:
    subcat_d[(cat, subcat)] = ([], [], [])

subsys_d = {}
for (cat, subcat, subsys) in subsyses:
    subsys_d[(cat, subcat, subsys)] = ([], [], [])

roles_d = {}
count = 1
roles_url = {}
url_list = []
for (cat, subcat, subsys, role) in roles:
    roles_d[(cat, subcat, subsys, role)] = ([], [], [])
    
    url = "role-%sXX%sXX%sXX%s" % (cat, subcat, subsys, role[:15].replace('/', 'XX'))
    n = 1
    new_url = url + '-0'
    while new_url in url_list:
        new_url = url + '-'+str(n)
        n = n+1
    url_list.append(new_url)
    roles_url[(cat, subcat, subsys, role)] = new_url
    #print (cat,subcat,subsys,role)
    #print new_url
        
for gene, v in g1_genes_with_subsystems.items():
    for (cat, subcat, subsys, role) in v:
        cat_d[cat][0].append(gene)
        subcat_d[(cat,subcat)][0].append(gene)
        subsys_d[(cat,subcat,subsys)][0].append(gene)
        roles_d[(cat,subcat,subsys,role)][0].append(gene)

for gene, v in g2_genes_with_subsystems.items():
    for (cat, subcat, subsys, role) in v:
        cat_d[cat][1].append(gene)
        subcat_d[(cat,subcat)][1].append(gene)
        subsys_d[(cat,subcat,subsys)][1].append(gene)
        roles_d[(cat,subcat,subsys,role)][1].append(gene)

for gene, v in g3_genes_with_subsystems.items():
    for (cat, subcat, subsys, role) in v:
        cat_d[cat][2].append(gene)
        subcat_d[(cat,subcat)][2].append(gene)
        subsys_d[(cat,subcat,subsys)][2].append(gene)
        roles_d[(cat,subcat,subsys,role)][2].append(gene)

if 1:
    fp = open(htmldir + 'g1.html', 'w')

    print >>fp, '<title>Ofp1 genes</title><h1>Ofp1 genes</h1>'
    print >>fp, '<table border=1>'
    print >>fp, '<tr><th>Gene</th><th>Orthologs (in Ofp2)</th><th>Homologs (in Ofp2)</th><th>Orthologs (in Neptunii)</th><th>Homologs (in Neptunii)</th></tr>'

    g_names = sorted([ (x, preprocess_name(x)) for x in genome1_seqs ])

    for g, name in g_names:
        print >>fp, '<tr><td>'
        print >>fp, gene_link(name)
        print >>fp, '</td><td>'
        print >>fp, preprocess_namelist(ortho_12.get(g))
        print >>fp, '</td><td>'
        print >>fp, len(homo_21.get(g, []))
        #print >>fp, preprocess_namelist(homo_12.get(g))
        print >>fp, '</td><td>'
        print >>fp, preprocess_namelist(ortho_13.get(g))
        print >>fp, '</td><td>'
        print >>fp, len(homo_13.get(g, []))
        #print >>fp, preprocess_namelist(homo_13.get(g))
        print >>fp, '</td><td>'
        
        cogs_id = genome1_cogs.get(g)
        if cogs_id:
            cogs_name = cogs_names[cogs_id]
            print >>fp, '<a href="cog-%s.html">%s - %s</a>' % (cogs_id, cogs_id, cogs_name)

        print >>fp, '</td><td>'

        x = []
        for (a, b, c, d) in g1_genes_with_subsystems.get(g, []):
            z = '%s::%s::%s::%s' % (category_link(a),
                                    subcategory_link(a, b),
                                    subsystem_link(a, b, c),
                                    role_link(roles_url[(a,b,c,d)], d))
            x.append(z)

        if x:
            x = "<br>".join(x)
        else:
            x = "<i>none</i>"
        print >>fp, x
        print >>fp, '</td></tr>'

        #print '1:', g

        # ---

        fp2 = open(htmldir + '%s-report.html' % name.replace('::', 'XX'), 'w')
        print >>fp2, '<title>%s</title><h1>%s</h1>' % (name, name)
        
        x = ortho_12.get(g)
        print >>fp2, 'Orthologs in Ofp2:', preprocess_namelist(x)
        print >>fp2, "<p>"

        x = ortho_13.get(g)
        print >>fp2, 'Orthologs in Neptunii:', preprocess_namelist(x)
        print >>fp2, "<p>"

        x = []
        for (a, b, c, d) in g1_genes_with_subsystems.get(g, []):
            z = '%s::%s::%s::%s' % (category_link(a),
                                    subcategory_link(a, b),
                                    subsystem_link(a, b, c),
                                    role_link(roles_url[(a,b,c,d)], d))
            x.append(z)

        if x:
            x = "Categories: <ul><li>" + "<li>".join(x) + "</ul>"
        else:
            x = "<i>No categories</i>"

        print >>fp2, x, "<P>"

        cogs_id = genome1_cogs.get(g)
        if cogs_id:
            cogs_name = cogs_names[cogs_id]
            print >>fp2, 'COG: <a href="cog-%s.html">%s - %s</a>' % (cogs_id, cogs_id, cogs_name)
        else:
            print >>fp2, "<i>No COG matches.</i>"

        print >>fp2, "<h2>Sequence:</h2>"
        print >>fp2, '>%s<br>%s' % (preprocess_name(g), "<br>".join(textwrap.wrap(genome1_seqs[g], 60)))

        fp2.close()

    print >>fp, '</table>'

    #####

    fp = open(htmldir + 'g2.html', 'w')

    print >>fp, '<title>Ofp2 genes</title><h1>Ofp2 genes</h1>'
    print >>fp, '<table border=1>'
    print >>fp, '<tr><th>Gene</th><th>Orthologs (in Ofp1)</th><th>Homologs (in Ofp1)</th><th>Orthologs (in Neptunii)</th><th>Homologs (in Neptunii)</th></tr>'

    g_names = sorted([ (x, preprocess_name(x)) for x in genome2_seqs ])

    for g, name in g_names:
        print >>fp, '<tr><td>'
        print >>fp, gene_link(name)
        print >>fp, '</td><td>'

        # ---
        print >>fp, preprocess_namelist(ortho_21.get(g))
        # ---
        print >>fp, '</td><td>'
        #print >>fp, preprocess_namelist(homo_21.get(g))
        print >>fp, len(homo_21.get(g, []))
        print >>fp, '</td><td>'
        print >>fp, preprocess_namelist(ortho_23.get(g))
        print >>fp, '</td><td>'
        #print >>fp, preprocess_namelist(homo_23.get(g))
        print >>fp, len(homo_23.get(g, []))
        print >>fp, '</td><td>'

        cogs_id = genome2_cogs.get(g)
        if cogs_id:
            cogs_name = cogs_names[cogs_id]
            print >>fp, '<a href="cog-%s.html">%s - %s</a>' % (cogs_id, cogs_id, cogs_name)

        print >>fp, '</td><td>'

        x = []
        for (a, b, c, d) in g2_genes_with_subsystems.get(g, []):
            z = '%s::%s::%s::%s' % (category_link(a),
                                    subcategory_link(a, b),
                                    subsystem_link(a, b, c),
                                    role_link(roles_url[(a,b,c,d)], d))
            x.append(z)

        if x:
            x = "<br>".join(x)
        else:
            x = "<i>none</i>"

        print >>fp, x
        print >>fp, '</td></tr>'
        #print '2:', g

        # ---

        fp2 = open(htmldir + '%s-report.html' % name, 'w')

        fp2 = open(htmldir + '%s-report.html' % name.replace('::', 'XX'), 'w')
        print >>fp2, '<title>%s</title><h1>%s</h1>' % (name, name)
        
        x = ortho_21.get(g)
        print >>fp2, 'Orthologs in Ofp1:', preprocess_namelist(x)
        print >>fp2, "<p>"

        x = ortho_23.get(g)
        print >>fp2, 'Orthologs in Neptunii:', preprocess_namelist(x)
        print >>fp2, "<p>"

        x = []
        for (a, b, c, d) in g2_genes_with_subsystems.get(g, []):
            z = '%s::%s::%s::%s' % (category_link(a),
                                    subcategory_link(a, b),
                                    subsystem_link(a, b, c),
                                    role_link(roles_url[(a,b,c,d)], d))
            x.append(z)

        if x:
            x = "Categories: <ul><li>" + "<li>".join(x) + "</ul>"
        else:
            x = "<i>No categories</i>"

        print >>fp2, x, "<P>"

        cogs_id = genome2_cogs.get(g)
        if cogs_id:
            cogs_name = cogs_names[cogs_id]
            print >>fp2, 'COG: <a href="cog-%s.html">%s - %s</a>' % (cogs_id, cogs_id, cogs_name)
        else:
            print >>fp2, "<i>No COG matches.</i>"

        print >>fp2, "<h2>Sequence:</h2>"
        print >>fp2, '>%s<br>%s' % (preprocess_name(g), "<br>".join(textwrap.wrap(genome2_seqs[g], 60)))

        fp2.close()

    print >>fp, '</table>'

    ####

    fp = open(htmldir + 'g3.html', 'w')

    print >>fp, '<title>Neptunii genes</title><h1>Neptunii genes</h1>'
    print >>fp, '<table border=1>'
    print >>fp, '<tr><th>Gene</th><th>Orthologs (in Ofp1)</th><th>Homologs (in Ofp1)</th><th>Orthologs (in Ofp2)</th><th>Homologs (in Ofp2)</th></tr>'

    g_names = sorted([ (x, preprocess_name(x)) for x in genome3_seqs ])

    for g, name in g_names:
        print >>fp, '<tr><td>'
        print >>fp, gene_link(name)
        print >>fp, '</td><td>'

        # ---
        print >>fp, preprocess_namelist(ortho_31.get(g))
        # ---
        print >>fp, '</td><td>'
        #print >>fp, preprocess_namelist(homo_31.get(g))
        print >>fp, len(homo_21.get(g, []))
        print >>fp, '</td><td>'
        print >>fp, preprocess_namelist(ortho_32.get(g))
        print >>fp, '</td><td>'
        #print >>fp, preprocess_namelist(homo_32.get(g))
        print >>fp, len(homo_23.get(g, []))
        print >>fp, '</td><td>'

        cogs_id = genome3_cogs.get(g)
        if cogs_id:
            cogs_name = cogs_names[cogs_id]
            print >>fp, '<a href="cog-%s.html">%s - %s</a>' % (cogs_id, cogs_id, cogs_name)

        print >>fp, '</td><td>'

        x = []
        for (a, b, c, d) in g3_genes_with_subsystems.get(g, []):
            z = '%s::%s::%s::%s' % (category_link(a),
                                    subcategory_link(a, b),
                                    subsystem_link(a, b, c),
                                    role_link(roles_url[(a,b,c,d)], d))
            x.append(z)

        if x:
            x = "<br>".join(x)
        else:
            x = "<i>none</i>"

        print >>fp, x
        print >>fp, '</td></tr>'
        #print '3:', g

        # ---

        fp2 = open(htmldir + '%s-report.html' % name, 'w')

        fp2 = open(htmldir + '%s-report.html' % name.replace('::', 'XX'), 'w')
        print >>fp2, '<title>%s</title><h1>%s</h1>' % (name, name)
        
        x = ortho_31.get(g)
        print >>fp2, 'Orthologs in Ofp1:', preprocess_namelist(x)
        print >>fp2, "<p>"

        x = ortho_32.get(g)
        print >>fp2, 'Orthologs in Neptunii:', preprocess_namelist(x)
        print >>fp2, "<p>"

        x = []
        for (a, b, c, d) in g3_genes_with_subsystems.get(g, []):
            z = '%s::%s::%s::%s' % (category_link(a),
                                    subcategory_link(a, b),
                                    subsystem_link(a, b, c),
                                    role_link(roles_url[(a,b,c,d)], d))
            x.append(z)

        if x:
            x = "Categories: <ul><li>" + "<li>".join(x) + "</ul>"
        else:
            x = "<i>No categories</i>"

        print >>fp2, x, "<P>"

        cogs_id = genome3_cogs.get(g)
        if cogs_id:
            cogs_name = cogs_names[cogs_id]
            print >>fp2, 'COG: <a href="cog-%s.html">%s - %s</a>' % (cogs_id, cogs_id, cogs_name)
        else:
            print >>fp2, "<i>No COG matches.</i>"

        print >>fp2, "<h2>Sequence:</h2>"
        print >>fp2, '>%s<br>%s' % (preprocess_name(g), "<br>".join(textwrap.wrap(genome3_seqs[g], 60)))

        fp2.close()

    print >>fp, '</table>'

###

###

index_fp = open(htmldir + 'categories.html', 'w')
print >>index_fp, '<title>Categories</title><h1>Categories</h1>'

for cat, v in cat_d.items():
    print '**', cat
    g1s, g2s, g3s = v
    
    fp = open(htmldir + 'category-%s.html' % cat, 'w')

    print >>index_fp, "<li>", category_link(cat)

    print >>fp, '<title>%s</title><h1>%s</h1>' % (cat, cat)

    print 'Subcategories:',
    print >>fp, '<ul>'
    for (a, b) in subcat_d:
        if a == cat:
            print >>fp, '<li>', subcategory_link(a,b)
    print >>fp, '</ul>'

    print >>fp, 'g1:', preprocess_namelist(g1s), '<p>'
    print >>fp, 'g2:', preprocess_namelist(g2s), '<p>'
    print >>fp, 'g3:', preprocess_namelist(g3s), '<p>'

index_fp.close()

for (cat, subcat), v in subcat_d.items():
    print '**', cat, subcat
    g1s, g2s, g3s = v
    
    fp = open(htmldir + 'subcategory-%sXX%s.html' % (cat, subcat,), 'w')

    print >>fp, '<title>%s::%s</title><h1>%s::%s</h1>' % (cat, subcat, cat, subcat)

    print 'Subsystems:'
    print >>fp, '<ul>'
    for (a, b, c) in subsys_d:
        if a == cat and b == subcat:
            print >>fp, '<li>', subsystem_link(a,b,c)
    print >>fp, '</ul>'

    print >>fp, 'g1:', preprocess_namelist(g1s), '<p>'
    print >>fp, 'g2:', preprocess_namelist(g2s), '<p>'
    print >>fp, 'g3:', preprocess_namelist(g3s), '<p>'

for (cat, subcat, subsys), v in subsys_d.items():
    print '**', cat, subcat, subsys
    g1s, g2s, g3s = v
    
    fp = open(htmldir + 'subsys-%sXX%sXX%s.html' % (cat, subcat, subsys), 'w')

    print >>fp, '<title>%s::%s::%s</title><h1>%s::%s::%s</h1>' % (cat, subcat, subsys, cat, subcat, subsys)

    print >>fp, 'Roles:'
    print >>fp, '<ul>'
    for (a, b, c, d) in roles:
        if a == cat and b == subcat and c == subsys:
            print >>fp, '<li>', role_link(roles_url[(a,b,c,d)],d)
    print >>fp, '</ul>'

    print >>fp, 'g1:', preprocess_namelist(g1s), '<p>'
    print >>fp, 'g2:', preprocess_namelist(g2s), '<p>'
    print >>fp, 'g3:', preprocess_namelist(g3s), '<p>'

for (cat, subcat, subsys, role), v in roles_d.items():
    g1s, g2s, g3s = v
    
    fp = open(htmldir + '%s.html' % (roles_url[(cat, subcat, subsys, role)]), 'w')

    print >>fp, '<title>%s::%s::%s::%s</title><h1>%s::%s::%s::%s</h1>' % (cat, subcat, subsys, role, cat, subcat, subsys, role)
    print >>fp, 'g1:', preprocess_namelist(g1s), '<p>'
    print >>fp, 'g2:', preprocess_namelist(g2s), '<p>'
    print >>fp, 'g3:', preprocess_namelist(g3s), '<p>'

###

print 'sorting and outputting COG matches'

genome1_revcogs = {}
for k, v in genome1_cogs.items():
    x = genome1_revcogs.get(v, [])
    x.append(k)
    genome1_revcogs[v] = x

genome2_revcogs = {}
for k, v in genome2_cogs.items():
    x = genome2_revcogs.get(v, [])
    x.append(k)
    genome2_revcogs[v] = x

genome3_revcogs = {}
for k, v in genome3_cogs.items():
    x = genome3_revcogs.get(v, [])
    x.append(k)
    genome3_revcogs[v] = x

all_cogs = set()
all_cogs.update(genome1_revcogs.keys())
all_cogs.update(genome2_revcogs.keys())
all_cogs.update(genome3_revcogs.keys())

indexfp = open(htmldir + 'cogindex.html', 'w')

print >>indexfp, "<title>COGs</title><H2>COGs</h2><ul>"

x = []
for cog in all_cogs:
    g1list = genome1_revcogs.get(cog, [])
    g2list = genome2_revcogs.get(cog, [])
    g3list = genome3_revcogs.get(cog, [])

    x.append((len(g1list) + len(g2list) + len(g3list), cog))

for (sumcount, cog) in reversed(sorted(x)):
    detail = cogs_names[cog]
    fp = open(htmldir + 'cog-%s.html' % cog, 'w')
    print >>fp, "<title>%s - %s</title><h1>%s - %s</h1>" % (detail, cog,
                                                            detail, cog)

    g1list = genome1_revcogs.get(cog, [])
    g2list = genome2_revcogs.get(cog, [])
    g3list = genome3_revcogs.get(cog, [])

    print >>fp, "Ofp1:", preprocess_namelist(g1list), "<p>"
    print >>fp, "Ofp2:", preprocess_namelist(g2list), "<p>"
    print >>fp, "Neptunii:", preprocess_namelist(g3list), "<p>"

    fp.close()

    print >>indexfp, "<li> (%d/%d/%d) <a href='cog-%s.html'>%s - %s</a>" % (len(g1list), len(g2list), len(g3list), cog, detail, cog)

print >>indexfp, "</ul>"

indexfp.close()

###

index_fp = open(htmldir + 'index.html', 'w')
print >>index_fp, '<title>The Symbiont Site</title>'
print >>index_fp, '<a href="g1.html">Genes from Ofp1</a><p><a href="g2.html">Genes from Ofp2</a><p><A href="g3.html">Genes from Neptunii</a><p><a href="categories.html">Functional categories</a><p><a href="cogindex.html">COG list</a>'
