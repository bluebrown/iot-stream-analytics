module.exports = {
  name: 'parameter',
  generator: function (faker, options) {
    const data = {
      deviceId: options.clientId,
      parameterId: faker.datatype.number({ min: 1, max: (60000 / 4) / options.messageInterval, precision: 1 }),
      state: faker.helpers.arrayElement(['OK', 'OK', 'OK', 'REPLACE', 'OK', 'OK', 'OK']),
    };
    if (data.state === 'OK') {
      data.value = faker.datatype.number({ min: 1, max: 100, precision: 0.01 });
    }
    data.timestamp = new Date().toISOString();
    return { message: JSON.stringify(data) };
  }
}
