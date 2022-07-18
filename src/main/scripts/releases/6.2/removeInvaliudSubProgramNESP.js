//This scripts removes the invalid NESP 1 - Northern Australia Hub

db.hub.update({hubId:'a0c69ce5-a2fc-4dfe-a387-468a4c916685'}, {$pull: {"supportedPrograms" : 'NESP 1 - Northern Australia Hub'}})