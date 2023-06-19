all: results_files js_files json_files

results_files: allres {%- for res in results %} {{res}}_res.mat {% endfor %}

allres:
	omc allres.mos

js_files: {%- for res in results %} js/{{res}}.js js/{{res}}.js.gz {% endfor %}

json_files: {%- for res in results %} json/{{res}}.json json/{{res}}.json.gz {% endfor %}

{% for res in results %}
{{res}}_res.mat {{res}}_init.xml {{res}}: {{results[res]["path"]}}
	echo "Simulating {{res}}..."
	omc {{res}}.mos
	echo "...done with {{res}}"

json/{{res}}.json: {{res}}_init.xml ../tojson.py
	-mkdir json
	../tojson.py {{res}}_init.xml json/{{res}}.json

json/{{res}}.json.gz: json/{{res}}.json
	(cd json; gzip -fk {{res}}.json)

js/{{res}}.js:  {{results[res]["path"]}}
	-mkdir js
	omc {{res}}-js.mos
	-mv {{res}}_node.js js/{{res}}_node.js
	cp {{res}}_init.xml js/{{res}}_init.xml
	cp {{res}}_info.xml js/{{res}}_info.xml
	mv {{res}}.js js/{{res}}.js

js/{{res}}.js.gz: js/{{res}}.js
	(cd js; gzip -fk {{res}}.js)
	-(cd js; gzip -fk {{res}}_init.xml)
	-(cd js; gzip -fk {{res}}_info.xml)

{% endfor %}

exes.tar.gz: {%- for res in results %} {{res}} {{res}}_init.xml json/{{res}}.json {% endfor %}
	tar zcf exes.tar.gz {%- for res in results %} {{res}} {{res}}_init.xml json/{{res}}.json {% endfor %} json/*-case.json 

tidy:
	-rm -f *.o *.c *.h *.libs *.log *.makefile *.fmutmp _FMU.* *_prof.*
	-rm -f *.fmu
	{% for res in results -%}
	-rm -f {{res}}
	{% endfor %}
