const mc = require('/opt/mc-client/node_modules/minecraft-protocol');
const clients = ['ProbeAlice', 'ProbeBob'].map(username => {
  const client = mc.createClient({
    host: '127.0.0.1', port: 25565, username,
    version: '26.1', auth: 'offline', disableChatSigning: true
  });
  client.on('playerJoin', () => console.log(JSON.stringify({stage: 'playerJoin', username})));
  client.on('position', packet => {
    client.write('teleport_confirm', {teleportId: packet.teleportId});
  });
  client.on('error', error => console.error(username, error.stack));
  client.on('disconnect', packet => console.error(username, JSON.stringify(packet)));
  client.on('end', () => console.log(JSON.stringify({stage: 'end', username})));
  return client;
});
process.on('SIGTERM', () => {
  for (const client of clients) client.end();
  process.exit(0);
});
