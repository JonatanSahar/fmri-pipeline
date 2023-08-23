function rawvmp = get_raw_vmp()
vmpfn = findFilesBVQX(fullfile('helper_functions','blank_MNI_3x3res.vmp'));
rawvmp = BVQXfile(vmpfn{1});

end