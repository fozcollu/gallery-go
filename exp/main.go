package main

import (
	"fmt"

	"galleries.com/models"
)

const (
	host     = "localhost"
	port     = 5432
	user     = "jon"
	password = "your-password"
	dbname   = "lenslocked_dev"
)

func main() {
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)
	us, err := models.NewUserService(psqlInfo)
	if err != nil {
		panic(err)
	}
	defer us.Close()
	us.DestructiveReset()

	user := models.User{
		Name:     "Jon Calhoun",
		Email:    "jon@calhoun.io",
		Password: "jon",
		Remember: "abc123",
	}
	err = us.Create(&user)
	if err != nil {
		panic(err)
	}
	fmt.Printf("%+v\n", user)
	user2, err := us.ByRemember("abc123")
	if err != nil {
		panic(err)
	}
	fmt.Printf("%+v\n", *user2)
}
