const buildSRealmsWhere = (search: any) => {
  const predicates: any = {};

  if (search?.address) {
    predicates.address = search.address.toLowerCase();
  }

  return predicates;
};

export { buildSRealmsWhere };
