## packer.m

## TODO:
## + all ##FIXME comments :)
## + see https://github.com/octave-de/p/wiki

function packer (varargin)

switch nargin
    case 0
        print_help

    case 1

    	## packer init
    	## ===========
        if strcmp(varargin{1},"init")
        	packer_init()

        ## packer update
        ## =============
        elseif strcmp(varargin{1},"update")
        	packer_update()

        else
        	print_help
        endif

    case 2

    	## packer search|find <char>
    	## =========================
        if strcmp(varargin{1},"search")||strcmp(varargin{1},"find")
            ## FIXME
            # check if folder exist
            # check if packer.db file exist
            packer_search(varargin{2});

        ## packer install <char>
        ## =====================
        elseif strcmp(varargin{1},"install")
        	packer_install(varargin{2}); 

	## packer info <char>
	## ==================
	elseif strcmp(varargin{1},"info")
		infos=packer_info(varargin{2});
		if numel(infos)>0
			## FIXME
			# bad format...
			# fprintf("Name			Home		Version			License				deps\n")
			fprintf("%s \t %s \t %s \t %s \t %s\n", infos.name, infos.home, infos.version, infos.license, strjoin (infos.deps,',')) 
		endif


	## packer upgrade <char>
	## =====================
	## upgrade package
	## upgrade # everything

	## packer add <char>
	## =================
	## add package to local database

	## packer uninstall <char>
	## =======================
	## uninstall package

        else
		    print_help
        endif

    otherwise
        print_help
end

endfunction

function packer_update()

	installdir=pkg("prefix");
	if exist([installdir "/packer.db"])
		load([installdir "/packer.db"]);
		urlwrite(db.config{1,2}, [installdir "/sfnet.db"]);
		run ([installdir "/sfnet.db"]);
		db.sfnet=d.sfnet;
		save([installdir "/packer.db"],"db");
	else
		fprintf("packer.db database not found, please run packer init\n")
	endif

endfunction

function packer_init()

	installdir=pkg("prefix");
	if exist([installdir "/packer.db"])
		prompt = 'packer.db already exist. Do you realy want to reset it? y/n [n]: ';
		str = input(prompt,'s');
		if ~isempty(str)
		    if strcmp(str,'y')
		    	packer_getdb()
		    	run ([installdir "/sfnet.db"]);
		    	db=d;
		    	save([installdir "/packer.db"],"db");
		    endif
		endif
	else
		packer_getdb()
		run ([installdir "/sfnet.db"]);
		db=d;
		save([installdir "/packer.db"],"db");
	endif
endfunction

function packer_getdb()
	installdir=pkg("prefix");
	if exist(installdir,"dir")~=7
		mkdir(installdir);
	endif

#	dbpath=strcat(hdir,"/.octave/sfnet.db");
	urlwrite("https://raw.githubusercontent.com/octave-de/packer-utils/master/sfnet.m", [installdir "/sfnet.db"]);
endfunction

function infos=packer_info(package)
	installdir=pkg("prefix");
    load([installdir "/packer.db"]);
    [r,~]=find(strcmp(db.sfnet,package));
    if numel(r)==0
    	fprintf("%s not found or unknown.\n", package)
    	infos=[];
    else
    	infos.home=db.sfnet{r,1};
    	infos.name=db.sfnet{r,2};
    	infos.version=db.sfnet{r,3};
    	infos.license=db.sfnet{r,5};
    	infos.deps=db.sfnet{r,7};
    endif
endfunction

function packer_install(package)
	if exist(package,"file")
		fprintf("Installing %s\n",package)
#		eval(fprintf("pkg install %s",package))
	else
		installdir=pkg("prefix");
		load([installdir "/packer.db"]);
		[r,~]=find(strcmp(db.sfnet,package));
		if numel(r)==0
			fprintf("%s not found or unknown.\n", package)
		else
			dep=packer_dependencies(r,package,db);
			if numel(dep)>0
				[dep,idx]=unique (dep,"first");
				## FIXME
				# reindexing...bad way?!
				dep(idx,1)=dep;

				## install deps
				for n = rows(dep):-1:1
					fprintf("Installing %s\n", dep{n})
#					eval(fprintf("pkg install -forge %s",dep{n});
				endfor
			endif

			## install package
			fprintf("Installing %s\n", package)
#			eval(fprintf("pkg install -forge %s", package);
		endif
	endif
endfunction

function dep=packer_dependencies(r,package,db)
	## FIXME
	# Version-Number handling is missing
	dep=db.sfnet{r,7};
	dep=cell2mat(regexp(dep,"[a-z\-]+", "match"));
	# 1,1 is alway octave (version nr)dep?
	dep=dep(2:end,:);
	dep=packer_add_dep(dep,db);
endfunction

function dep=packer_add_dep(dep)
	installdir=pkg("prefix");
	load([installdir "/packer.db"]);
	for n = 1:rows(dep)
		[r,~]=find(strcmp(db.sfnet,dep{n,1}));
		newdep=db.sfnet{r,7};
		newdep=cell2mat(regexp(newdep,"[a-z\-]+", "match"));
		if strfind (newdep{1,1},"octave")
			newdep=newdep(2:end,1);
		endif
		if numel(newdep)>0
			moredep=packer_add_dep(newdep);
		else 
			moredep=[];
		endif
		if numel(newdep)>0
			dep=[dep; newdep];
		endif
		if numel(moredep)>0
			dep=[dep; moredep];
		endif
	endfor
endfunction

function packer_search(searchstring)
	installdir=pkg("prefix");
	load([installdir "/packer.db"]);
	[r,~]=find(strcmp(db.sfnet,searchstring));
	if numel(r)==0
		r=cellfun(@(str) rfind(str, searchstring), db.sfnet);
		if numel(r)==0
			fprintf("%s not found or unknown.\n", searchstring)
		else
			[r,~]=find(r==1);
			fprintf("Function %s is member of %s/%s\n", searchstring, db.sfnet{r,1}, db.sfnet{r,2})
		endif
	else
		fprintf("%s/%s %s\n", db.sfnet{r,1}, db.sfnet{r,2}, db.sfnet{r,3})
	endif
endfunction

function result = rfind(str, pattern)
	if ischar(str)
		result = strcmp(str, pattern);
	elseif iscell(str)
		result = cellfun(@(str) rfind(str,pattern), str);
		result = any(result(:));
	else
		result = false;
	endif
endfunction

function print_help()
	disp("comming soon")
endfunction
