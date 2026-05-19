### Generate random comkey JSON

from email import parser
import json
import random
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--n", type=int, default=6,help="Value n (=d in paper), corresponds to number of comkey rows -1 (default: 6)")
    parser.add_argument("--k", type=int, default=13, help="Value k (=2d+1 in paper), corresponds to number of comkey columns) (default: 13)")
    parser.add_argument("--N", type=int, default=486,help="Polynomial degree bound (default: 486)")
    parser.add_argument("--q", type=int,default=18446744069414584321,help="Upper bound on comkey entries (default: goldilocks)")
    parser.add_argument("--out", type=str, default="comkey.json")
    args = parser.parse_args()

    n, k, N, q = args.n, args.k, args.N, args.q

    comkey = [
        [
            [random.randint(0, q) for _ in range(N)]
            for _ in range(k)
        ]
        for _ in range(n+1)
    ]

    with open(args.out, "w") as f:
        json.dump({"comkey": comkey}, f, indent=2)

    print(f"Generated {args.out}")

if __name__ == "__main__":
    main()

