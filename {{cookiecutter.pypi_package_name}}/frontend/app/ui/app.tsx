"use client";

import {AppSidebar} from "@/components/app-sidebar";
import {SidebarInset, SidebarProvider, SidebarTrigger} from "@/components/ui/sidebar";
import {Separator} from "@/components/ui/separator";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList, BreadcrumbPage,
  BreadcrumbSeparator
} from "@/components/ui/breadcrumb";
import {Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card";
import {Button} from "@/components/ui/button";
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {useState} from "react";

export default function App({ user }: { user: any }) {
  const [responseText, setResponseText] = useState("");
  const [name, setName] = useState("");
  const apiUrl = process.env.NEXT_PUBLIC_BACKEND_URL; // FIXME: This does not work in prod

  const getHello = async () => {
    var url = `${apiUrl}/hello`
    if (name) {
      url = `${url}/${name}`
    }

    let data = await fetch(url);
    let response = await data.json();
    setResponseText(JSON.stringify(response, null, 2));
  }

  const putHello = async () => {
    let data = await fetch(`${apiUrl}/hello`, {
      method: 'PUT',
    });
    let response = await data.json();
    setResponseText(JSON.stringify(response, null, 2));
  }

  return (
    <SidebarProvider>
      <AppSidebar user={user}/>
      <SidebarInset>
        <header className="flex h-16 shrink-0 items-center gap-2 transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12">
          <div className="flex items-center gap-2 px-4">
            <SidebarTrigger className="-ml-1" />
            <Separator
              orientation="vertical"
              className="mr-2 data-[orientation=vertical]:h-4"
            />
            <Breadcrumb>
              <BreadcrumbList>
                <BreadcrumbItem className="hidden md:block">
                  <BreadcrumbLink href="#">
                    First App
                  </BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator className="hidden md:block" />
                <BreadcrumbItem>
                  <BreadcrumbPage>LLM</BreadcrumbPage>
                </BreadcrumbItem>
              </BreadcrumbList>
            </Breadcrumb>
          </div>
        </header>
        <div className="flex flex-1 items-center justify-center p-4">
          <Card className="w-full max-w-sm">
            <CardHeader>
              <CardTitle>Request Hello</CardTitle>
              <CardDescription>
                Click any of the buttons below to make a request to the API.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form>
                <div className="flex flex-col gap-6">
                  <div className="grid gap-2">
                    <Label htmlFor="name">Name</Label>
                    <Input
                      id="name"
                      type="name"
                      onChange={(e) => setName(e.target.value)}
                    />
                  </div>
                </div>
              </form>
            </CardContent>
            <CardContent>
              <div className="grid gap-2">
                <Label>Result</Label>
                <div className="min-h-[40px] w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm">
                  {responseText || "No result yet..."}
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex-col gap-2">
              <Button variant="outline" className="w-full" onClick={getHello}>
                GET: /api/hello
              </Button>
              <Button variant="outline" className="w-full" onClick={putHello}>
                PUT: /api/hello
              </Button>
            </CardFooter>
          </Card>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
}
