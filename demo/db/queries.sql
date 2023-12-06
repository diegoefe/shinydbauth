-- login user
-- Warning lacks user/password validation!
SELECT
    u.role,
    u.provincia,
    group_concat(p.perm_name, '|') perms,
    r.level,
    u.survey_user
FROM users u
    INNER JOIN roles r ON(u.role=r.role_name)
    INNER JOIN roles_perms rp ON(r.id=rp.id_role)
    INNER JOIN perms p ON(p.id=rp.id_perm)
WHERE username = 'gman'
    AND password = '3aedf4ff6b20a24414eb39e7555f3fa634289ea73151fc8d6ede3e25b2d441e0'
    AND is_locked=false
GROUP BY 1, 2, 4, 5;


-- login user
-- Warning lacks exiting user/password validation!
update users 
    set password = 'new_hashed_password'
    where username = 'gman';
